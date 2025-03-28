# Guide d'utilisation

Ce document décrit comment utiliser les scripts Transibase pour convertir des données JSON en CSV conformes aux exigences du DGEQ.

## Table des matières
- [Principes de base](#principes-de-base)
- [Syntaxe générale](#syntaxe-générale)
- [Filtrage par année](#filtrage-par-année)
- [Exemples d'utilisation](#exemples-dutilisation)
- [Comportement avec un fichier de sortie existant](#comportement-avec-un-fichier-de-sortie-existant)

## Principes de base

Tous les scripts Transibase fonctionnent de la même manière, quel que soit l'environnement d'exécution:
1. Ils lisent un fichier JSON exporté depuis Craft Commerce
2. Ils extraient des informations spécifiques liées aux dons
3. Ils génèrent un fichier CSV formaté selon les exigences du DGEQ

## Syntaxe générale

La syntaxe générale pour tous les scripts est la suivante:

```
[commande] transibase_dgeq_convert.[extension] <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Où:
- `[commande]` est la commande spécifique à l'environnement (node, python3, etc.)
- `<fichier_entrée.json>` est le chemin vers le fichier JSON d'entrée (obligatoire)
- `<fichier_sortie.csv>` est le chemin vers le fichier CSV à générer (obligatoire)
- `[année]` est l'année pour filtrer les transactions (optionnel, format YYYY)

Exemples pour chaque environnement:

```bash
# Node.js (JavaScript)
node transibase_dgeq_convert.js donations.json rapport.csv

# Node.js (TypeScript)
npx ts-node transibase_dgeq_convert_node.ts donations.json rapport.csv

# Deno
deno run --allow-read --allow-write transibase_dgeq_convert_deno.ts donations.json rapport.csv

# Bun
bun transibase_dgeq_convert_bun.ts donations.json rapport.csv

# PHP
php transibase_dgeq_convert.php donations.json rapport.csv

# Python
python3 transibase_dgeq_convert.py donations.json rapport.csv
```

## Filtrage par année

Pour filtrer les transactions par année, ajoutez l'année en format YYYY comme troisième argument:

```bash
node transibase_dgeq_convert.js donations.json rapport_2024.csv 2024
```

Cela ne gardera que les transactions dont la date est dans l'année spécifiée.

## Exemples d'utilisation

### Exemple 1: Conversion simple

Pour convertir toutes les transactions d'un fichier JSON:

```bash
node transibase_dgeq_convert.js dons_campagne.json rapport_dgeq.csv
```

### Exemple 2: Filtrer par année

Pour extraire seulement les transactions de 2023:

```bash
python3 transibase_dgeq_convert.py dons_campagne.json rapport_2023.csv 2023
```

### Exemple 3: Utilisation avec un chemin complet

```bash
php transibase_dgeq_convert.php /home/user/downloads/export.json /home/user/documents/rapport.csv
```

### Exemple 4: Exécution directe (scripts rendus exécutables)

Sur Linux/macOS, après avoir rendu le script exécutable avec `chmod +x`:

```bash
./transibase_dgeq_convert.py export.json rapport.csv
```

## Comportement avec un fichier de sortie existant

Si le fichier de sortie existe déjà, le script vous demandera si vous souhaitez l'écraser:

```
Le fichier rapport.csv existe déjà. Voulez-vous l'écraser ? (o/n)
```

- Répondez `o` pour écraser le fichier existant
- Répondez `n` pour annuler l'opération

## Format du fichier de sortie

Le fichier CSV généré contient les colonnes suivantes:

1. **reference**: Identifiant de la dernière transaction
2. **email**: Adresse email du client
3. **prenom**: Prénom du donateur
4. **nom**: Nom de famille du donateur
5. **dateNaissance**: Date de naissance au format YYYY-MM-DD
6. **donationAmount**: Montant du don
7. **transactionDate**: Date de la transaction au format YYYY-MM-DD

Exemple de contenu du fichier CSV:

```csv
"reference","email","prenom","nom","dateNaissance","donationAmount","transactionDate"
"TXN-10001","exemple1@email.com","Jean","Tremblay","1985-06-15","25.00","2023-04-15"
"TXN-10004","exemple3@email.com","Pierre","Lavoie","1992-03-08","100.00","2024-01-10"
```

Tous les champs sont encadrés par des guillemets doubles et les guillemets dans les valeurs sont échappés selon le standard CSV (RFC 4180).