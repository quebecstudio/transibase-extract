#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Transibase 1.0 - Extracteur de données JSON vers CSV

Ce script permet d'extraire des données spécifiques depuis les commandes Craft Commerce
exportées en JSON et de les convertir en format CSV.

Ce script est disponible en plusieurs versions:
- JavaScript (Node.js): transibase_dgeq_convert.js
- TypeScript (Node.js): transibase_dgeq_convert_node.ts
- TypeScript (Deno): transibase_dgeq_convert_deno.ts
- TypeScript (Bun): transibase_dgeq_convert_bun.ts
- Python 3: transibase_dgeq_convert.py
- PHP 8.3+: transibase_dgeq_convert.php
- Go: transibase_dgeq_convert.go

@copyright 2025 Québec Studio
@license GNU General Public License v3.0 (GPL-3.0)
@author Québec Studio
@version 1.0.0

Ce script fait partie du logiciel Transibase 1.0 développé par Québec Studio.

Ce programme est un logiciel libre ; vous pouvez le redistribuer et/ou le modifier
selon les termes de la Licence Publique Générale GNU publiée par la Free Software
Foundation ; soit la version 3 de la licence, soit (à votre gré) toute version
ultérieure.

Ce programme est distribué dans l'espoir qu'il sera utile, mais SANS AUCUNE GARANTIE ;
sans même la garantie tacite de QUALITÉ MARCHANDE ou d'ADÉQUATION à UN BUT PARTICULIER.
Consultez la Licence Publique Générale GNU pour plus de détails.

Vous devriez avoir reçu une copie de la Licence Publique Générale GNU avec ce programme ;
si ce n'est pas le cas, consultez <https://www.gnu.org/licenses/licenses.fr.html>.
"""

import json
import csv
import sys
import os
import re
from datetime import datetime

def extract_data(json_data, filter_year=None):
    """
    Extrait les données demandées du JSON fourni
    
    Args:
        json_data: Les données JSON à traiter
        filter_year: Année pour filtrer les transactions (optionnel)
        
    Returns:
        Liste des données extraites
    """
    # S'assurer que json_data est une liste
    data_array = json_data if isinstance(json_data, list) else [json_data]
    
    extracted_data = []
    
    for item in data_array:
        # Obtenir la dernière transaction
        last_transaction = {}
        if 'transactions' in item and item['transactions'] and len(item['transactions']) > 0:
            last_transaction = item['transactions'][-1]
        
        # Convertir la date de la transaction au format AAAA-MM-JJ
        transaction_date = ''
        if 'dateCreated' in last_transaction and last_transaction['dateCreated']:
            date_str = last_transaction['dateCreated']
            # Si la date est au format ISO
            if 'T' in date_str:
                transaction_date = date_str.split('T')[0]
            # Si la date est dans un autre format, tentative de conversion
            else:
                try:
                    date_obj = datetime.strptime(date_str, '%Y-%m-%d')
                    transaction_date = date_obj.strftime('%Y-%m-%d')
                except ValueError:
                    try:
                        # Essayer de parser avec plusieurs formats courants
                        for fmt in ['%d/%m/%Y', '%m/%d/%Y', '%Y/%m/%d']:
                            try:
                                date_obj = datetime.strptime(date_str, fmt)
                                transaction_date = date_obj.strftime('%Y-%m-%d')
                                break
                            except ValueError:
                                continue
                        if not transaction_date:  # Si aucun format n'a fonctionné
                            transaction_date = date_str
                    except Exception:
                        transaction_date = date_str
        
        # Extraire les informations demandées
        email = item.get('customer', {}).get('email', '')
        
        # Extraire les données des options
        prenom = ''
        nom = ''
        date_naissance = ''
        donation_amount = ''
        
        if 'lineItems' in item and item['lineItems'] and len(item['lineItems']) > 0:
            options = item['lineItems'][0].get('options', {})
            prenom = options.get('prenom', '')
            nom = options.get('nom', '')
            date_naissance = options.get('dateNaissance', '')
            donation_amount = options.get('donationAmount', '')
        
        extracted_item = {
            'reference': last_transaction.get('reference', ''),
            'email': email,
            'prenom': prenom,
            'nom': nom,
            'dateNaissance': date_naissance,
            'donationAmount': donation_amount,
            'transactionDate': transaction_date
        }
        
        # Filtrer par année si spécifiée
        if filter_year:
            year = transaction_date.split('-')[0] if transaction_date else ''
            if year == filter_year:
                extracted_data.append(extracted_item)
        else:
            extracted_data.append(extracted_item)
    
    return extracted_data

def convert_to_csv(data, output_file):
    """
    Convertit les données extraites en CSV et les écrit dans un fichier
    
    Args:
        data: Les données à convertir
        output_file: Le fichier de sortie
    """
    # En-têtes CSV
    header = ['reference', 'email', 'prenom', 'nom', 'dateNaissance', 'donationAmount', 'transactionDate']
    
    # Écrire dans le fichier CSV
    with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=header, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        writer.writerows(data)

def main():
    """Fonction principale"""
    # Traitement des arguments de la ligne de commande
    if len(sys.argv) < 3:
        print('Usage: python transibase_dgeq_convert.py <inputFile> <outputFile> [year]')
        print('  inputFile: Chemin vers le fichier JSON d\'entrée')
        print('  outputFile: Chemin vers le fichier CSV de sortie')
        print('  year: (Optionnel) Année pour filtrer les transactions (format: YYYY)')
        sys.exit(1)
    
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    filter_year = sys.argv[3] if len(sys.argv) > 3 else None
    
    # Vérifier que le fichier d'entrée existe
    if not os.path.exists(input_file_path):
        print(f"Erreur: Le fichier d'entrée {input_file_path} n'existe pas.")
        sys.exit(1)
    
    # Vérifier le format de l'année si spécifiée
    if filter_year and not re.match(r'^\d{4}$', filter_year):
        print("Erreur: L'année doit être au format YYYY (ex: 2023).")
        sys.exit(1)
    
    # Vérifier si le fichier de sortie existe déjà
    if os.path.exists(output_file_path):
        answer = input(f"Le fichier {output_file_path} existe déjà. Voulez-vous l'écraser ? (o/n) ")
        if answer.lower() != 'o':
            print('Opération annulée.')
            sys.exit(0)
    
    try:
        # Lire le fichier JSON
        with open(input_file_path, 'r', encoding='utf-8') as file:
            file_content = file.read()
        
        # Traiter le contenu JSON
        try:
            json_data = json.loads(file_content)
        except json.JSONDecodeError:
            # Si le JSON est mal formé, essayer de le réparer
            try:
                json_data = json.loads(f"[{file_content}]")
            except json.JSONDecodeError:
                print("Erreur: Le fichier JSON est mal formé et ne peut pas être réparé automatiquement.")
                sys.exit(1)
        
        # Extraire les données avec filtre d'année si spécifié
        extracted_data = extract_data(json_data, filter_year)
        
        # Vérifier si des données ont été extraites
        if not extracted_data:
            if filter_year:
                print(f"Aucune transaction trouvée pour l'année {filter_year}.")
            else:
                print("Aucune transaction trouvée.")
            sys.exit(0)
        
        # Convertir en CSV et écrire le fichier
        convert_to_csv(extracted_data, output_file_path)
        
        print(f"Extraction réussie! Fichier CSV créé: {output_file_path}")
        print(f"Nombre d'entrées traitées: {len(extracted_data)}")
        
        if filter_year:
            print(f"Filtre appliqué: Année {filter_year}")
        
    except Exception as e:
        print(f"Erreur lors du traitement: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()