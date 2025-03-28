# Format des fichiers

Ce document décrit en détail les formats de fichiers d'entrée et de sortie utilisés par les scripts Transibase.

## Table des matières

- [Format d'entrée JSON](#format-dentrée-json)
  - [Structure générale](#structure-générale)
  - [Champs importants](#champs-importants)
  - [Exemple minimal](#exemple-minimal)
- [Format de sortie CSV](#format-de-sortie-csv)
  - [Structure du CSV](#structure-du-csv)
  - [Spécification technique](#spécification-technique)
  - [Exemple de sortie](#exemple-de-sortie)
- [Exportation depuis Craft Commerce](#exportation-depuis-craft-commerce)

## Format d'entrée JSON

### Structure générale

Le script attend un fichier JSON exporté depuis Craft Commerce, contenant des données de commandes. Ce fichier peut être:
- Un tableau d'objets de commande `[{...}, {...}, ...]`
- Un objet de commande unique `{...}`

### Champs importants

Le script extrait les informations suivantes:

1. **Référence de transaction**
   - Chemin: `transactions[dernier].reference`
   - Description: Identifiant unique de la dernière transaction associée à la commande

2. **Email du client**
   - Chemin: `customer.email`
   - Description: Adresse email du client/donateur

3. **Informations personnelles**
   - Chemin: `lineItems[0].options.prenom`
   - Chemin: `lineItems[0].options.nom`
   - Chemin: `lineItems[0].options.dateNaissance`
   - Description: Informations personnelles du donateur

4. **Montant du don**
   - Chemin: `lineItems[0].options.donationAmount`
   - Description: Montant du don

5. **Date de transaction**
   - Chemin: `transactions[dernier].dateCreated`
   - Description: Date de la transaction, convertie au format YYYY-MM-DD

### Exemple minimal

Voici un exemple minimal d'un objet JSON qui contient tous les champs nécessaires:

```json
{
  "customer": {
    "email": "donateur@exemple.com"
  },
  "lineItems": [
    {
      "options": {
        "prenom": "Jean",
        "nom": "Tremblay",
        "dateNaissance": "1975-06-15",
        "donationAmount": "100"
      }
    }
  ],
  "transactions": [
    {
      "reference": "TXN-12345",
      "dateCreated": "2023-05-10T14:30:00-04:00"
    }
  ]
}
```

## Format de sortie CSV

### Structure du CSV

Le fichier CSV généré contient les colonnes suivantes, dans cet ordre:

1. `reference` - Identifiant de la dernière transaction
2. `email` - Adresse email du client
3. `prenom` - Prénom du donateur
4. `nom` - Nom de famille du donateur
5. `dateNaissance` - Date de naissance au format YYYY-MM-DD
6. `donationAmount` - Montant du don
7. `transactionDate` - Date de la transaction au format YYYY-MM-DD

### Spécification technique

Le fichier CSV est généré selon les spécifications suivantes:

- **Encodage**: UTF-8
- **Séparateur**: Virgule (,)
- **Délimiteur de texte**: Guillemets doubles (")
- **Caractère d'échappement**: Les guillemets doubles à l'intérieur des valeurs sont échappés par un autre guillemet double ("")
- **Fin de ligne**: LF (\n) sur macOS/Linux, CRLF (\r\n) sur Windows
- **En-tête**: La première ligne contient les noms des colonnes

Ces spécifications sont conformes au standard RFC 4180.

### Exemple de sortie

Voici un exemple de contenu du fichier CSV généré:

```csv
"reference","email","prenom","nom","dateNaissance","donationAmount","transactionDate"
"TXN-12345","donateur@exemple.com","Jean","Tremblay","1975-06-15","100","2023-05-10"
"TXN-67890","autre@exemple.com","Marie","Gagnon","1982-11-23","50","2023-08-15"
```

## Exportation depuis Craft Commerce

Pour obtenir un fichier JSON compatible avec les scripts Transibase, suivez ces étapes dans Craft CMS:

1. **Connectez-vous au panneau d'administration**
   - Accédez à votre panneau d'administration Craft CMS

2. **Accédez à la section Commerce**
   - Dans le menu de gauche, cliquez sur **Commerce**
   - Puis sur **Commandes**

3. **Exportez les commandes**
   - Cliquez sur le bouton **Exporter...**
   - Dans les options d'exportation, choisissez:
     - **Type d'exportation** = Développé
     - **Format** = JSON
     - **Limite** = Aucune (ou choisissez une limite si nécessaire)
   - Cliquez sur **Exporter** pour télécharger le fichier JSON

4. **Utilisez le fichier téléchargé**
   - Le fichier JSON téléchargé peut maintenant être utilisé comme entrée pour les scripts Transibase

### Note sur les formats de date

Le script prend en charge plusieurs formats de date pour le champ `dateCreated`:

- Format ISO avec timezone (ex: `2023-05-10T14:30:00-04:00`)
- Format simple YYYY-MM-DD (ex: `2023-05-10`)
- Formats avec séparateurs slash: DD/MM/YYYY, MM/DD/YYYY, YYYY/MM/DD

Dans tous les cas, la date est standardisée au format YYYY-MM-DD dans le CSV de sortie.