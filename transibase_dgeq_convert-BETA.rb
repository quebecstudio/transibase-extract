#!/usr/bin/env ruby
# encoding: utf-8

=begin
Transibase 1.0 - Extracteur de données JSON vers CSV (Version Ruby)

Ce script permet d'extraire des données spécifiques depuis les commandes Craft Commerce
exportées en JSON et de les convertir en format CSV.

@copyright 2025 Québec Studio
@license GNU General Public License v3.0 (GPL-3.0)
@author Québec Studio
@version 1.0.0
=end

require 'json'
require 'csv'
require 'date'
require 'fileutils'

# Classe pour stocker les données extraites
class ExtractedData
  attr_accessor :reference, :email, :prenom, :nom, :date_naissance, :donation_amount, :transaction_date
  
  def initialize
    @reference = ''
    @email = ''
    @prenom = ''
    @nom = ''
    @date_naissance = ''
    @donation_amount = ''
    @transaction_date = ''
  end
  
  def to_hash
    {
      'reference' => @reference,
      'email' => @email,
      'prenom' => @prenom,
      'nom' => @nom,
      'dateNaissance' => @date_naissance,
      'donationAmount' => @donation_amount,
      'transactionDate' => @transaction_date
    }
  end
end

# Classe principale du convertisseur
class TransibaseConverter
  def initialize(filter_year = nil)
    @filter_year = filter_year
  end
  
  # Extrait les données demandées du JSON
  def extract_data(json_data)
    extracted_data = []
    
    # S'assurer que json_data est un tableau
    data_array = json_data.is_a?(Array) ? json_data : [json_data]
    
    data_array.each do |item|
      # Obtenir la dernière transaction
      last_transaction = {}
      if item['transactions'] && !item['transactions'].empty?
        last_transaction = item['transactions'].last
      end
      
      # Convertir la date de la transaction au format AAAA-MM-JJ
      transaction_date = ''
      if last_transaction['dateCreated']
        date_str = last_transaction['dateCreated']
        
        # Si la date est au format ISO
        if date_str.include?('T')
          transaction_date = date_str.split('T').first
        else
          # Si la date est dans un autre format, tentative de conversion
          begin
            date = Date.parse(date_str)
            transaction_date = date.strftime('%Y-%m-%d')
          rescue Date::Error
            transaction_date = date_str
          end
        end
      end
      
      # Extraire les informations de base
      email = item.dig('customer', 'email') || ''
      
      # Extraire les données des options
      prenom = ''
      nom = ''
      date_naissance = ''
      donation_amount = ''
      
      if item['lineItems'] && !item['lineItems'].empty? && item['lineItems'].first['options']
        options = item['lineItems'].first['options']
        prenom = options['prenom'] || ''
        nom = options['nom'] || ''
        date_naissance = options['dateNaissance'] || ''
        donation_amount = options['donationAmount'] || ''
      end
      
      extracted_item = ExtractedData.new
      extracted_item.reference = last_transaction['reference'] || ''
      extracted_item.email = email
      extracted_item.prenom = prenom
      extracted_item.nom = nom
      extracted_item.date_naissance = date_naissance
      extracted_item.donation_amount = donation_amount
      extracted_item.transaction_date = transaction_date
      
      # Filtrer par année si spécifiée
      if @filter_year
        year = transaction_date.split('-').first
        extracted_data << extracted_item if year == @filter_year
      else
        extracted_data << extracted_item
      end
    end
    
    extracted_data
  end
  
  # Convertit les données en format CSV et les écrit dans un fichier
  def convert_to_csv(data, output_file)
    headers = ['reference', 'email', 'prenom', 'nom', 'dateNaissance', 'donationAmount', 'transactionDate']
    
    CSV.open(output_file, 'w', write_headers: true, headers: headers) do |csv|
      data.each do |item|
        csv << item.to_hash.values_at(*headers)
      end
    end
  end
  
  # Processus principal d'extraction et de conversion
  def process(input_file_path, output_file_path)
    # Lire le fichier JSON
    begin
      file_content = File.read(input_file_path, encoding: 'utf-8')
    rescue => e
      raise "Impossible de lire le fichier d'entrée: #{e.message}"
    end
    
    # Traiter le contenu JSON
    begin
      json_data = JSON.parse(file_content)
    rescue JSON::ParserError
      # Si le JSON est mal formé, essayer de le réparer
      begin
        json_data = JSON.parse("[#{file_content}]")
      rescue JSON::ParserError => e
        raise "Le fichier JSON est mal formé et ne peut pas être réparé automatiquement: #{e.message}"
      end
    end
    
    # Extraire les données
    extracted_data = extract_data(json_data)
    
    # Vérifier si des données ont été extraites
    if extracted_data.empty?
      if @filter_year
        puts "Aucune transaction trouvée pour l'année #{@filter_year}."
      else
        puts "Aucune transaction trouvée."
      end
      return
    end
    
    # Convertir en CSV et écrire dans le fichier
    convert_to_csv(extracted_data, output_file_path)
    
    puts "Extraction réussie! Fichier CSV créé: #{output_file_path}"
    puts "Nombre d'entrées traitées: #{extracted_data.size}"
    
    puts "Filtre appliqué: Année #{@filter_year}" if @filter_year
  end
end

# Fonction pour demander à l'utilisateur s'il veut écraser un fichier existant
def ask_for_overwrite(file_path)
  print "Le fichier #{file_path} existe déjà. Voulez-vous l'écraser ? (o/n) "
  response = gets.chomp.downcase
  response == 'o'
end

# Point d'entrée du script
if __FILE__ == $PROGRAM_NAME
  # Vérification des arguments de ligne de commande
  if ARGV.size < 2
    puts "Usage: ruby transibase_dgeq_convert.rb <inputFile> <outputFile> [year]"
    puts "  inputFile: Chemin vers le fichier JSON d'entrée"
    puts "  outputFile: Chemin vers le fichier CSV de sortie"
    puts "  year: (Optionnel) Année pour filtrer les transactions (format: YYYY)"
    exit(1)
  end
  
  input_file_path = ARGV[0]
  output_file_path = ARGV[1]
  filter_year = ARGV[2]
  
  # Vérifier que le fichier d'entrée existe
  unless File.exist?(input_file_path)
    puts "Erreur: Le fichier d'entrée #{input_file_path} n'existe pas."
    exit(1)
  end
  
  # Vérifier le format de l'année si spécifiée
  if filter_year && !/^\d{4}$/.match(filter_year)
    puts "Erreur: L'année doit être au format YYYY (ex: 2023)."
    exit(1)
  end
  
  # Vérifier si le fichier de sortie existe déjà
  if File.exist?(output_file_path)
    unless ask_for_overwrite(output_file_path)
      puts "Opération annulée."
      exit(0)
    end
  end
  
  begin
    # Créer une instance du convertisseur
    converter = TransibaseConverter.new(filter_year)
    
    # Traiter les données
    converter.process(input_file_path, output_file_path)
  rescue => e
    puts "Erreur lors du traitement: #{e.message}"
    exit(1)
  end
end