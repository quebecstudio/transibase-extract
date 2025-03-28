# Transibase 1.0 - Extracteur JSON vers CSV

Ce script fait partie du logiciel Transibase 1.0 développé par Québec Studio.
Il permet d'extraire des données spécifiques à partir de fichiers JSON de commandes Craft Commerce et de les exporter dans un format CSV.

## Soutien

Québec Studio soutient l'Ukraine et son peuple dans sa quête de paix, de liberté et de souveraineté. 🇺🇦

Si vous ne soutenez pas cette cause, nous vous prions de ne pas utiliser nos logiciels, car ils s'adressent aux personnes qui souhaitent être du bon côté de l'histoire.

## Objectif

Ce script est conçu pour générer le document à fournir au Directeur général des élections du Québec (DGEQ) pour les partis municipaux. Le fichier CSV généré contient les données minimales requises par le DGEQ pour la conformité des rapports financiers des partis politiques municipaux.

## Prérequis

### Installation de Node.js

#### Sur Windows (PC)

1. **Télécharger l'installateur**
   - Allez sur le site officiel de Node.js : https://nodejs.org/fr/
   - Téléchargez la version LTS (Long Term Support) recommandée pour la plupart des utilisateurs
   
2. **Installer Node.js**
   - Exécutez le fichier .msi téléchargé
   - Suivez les instructions de l'assistant d'installation
   - Laissez cocher l'option "Ajouter à la variable PATH" pendant l'installation
   
3. **Vérifier l'installation**
   - Ouvrez l'invite de commande (cmd) ou PowerShell
   - Tapez les commandes suivantes pour vérifier que Node.js et npm sont installés correctement:
   ```
   node --version
   npm --version
   ```

#### Sur macOS

1. **Méthode avec l'installateur**
   - Allez sur le site officiel de Node.js : https://nodejs.org/fr/
   - Téléchargez la version LTS pour macOS (.pkg)
   - Exécutez le fichier .pkg téléchargé et suivez les instructions
   
2. **Méthode avec Homebrew** (recommandée si vous utilisez déjà Homebrew)
   - Si vous n'avez pas encore Homebrew, installez-le en exécutant dans le Terminal:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   - Installez Node.js avec Homebrew:
   ```
   brew install node
   ```
   
3. **Vérifier l'installation**
   - Ouvrez le Terminal
   - Tapez les commandes suivantes:
   ```
   node --version
   npm --version
   ```

## Utilisation du script

### Commandes de base

```bash
# Utilisation basique
node extract-json-to-csv.js input.json output.csv

# Avec filtrage par année (seulement les transactions de 2024)
node extract-json-to-csv.js input.json output.csv 2024
```

Si le fichier de sortie existe déjà, le script vous demandera si vous souhaitez l'écraser.

### Traitement par lots

Pour traiter plusieurs fichiers JSON:

```bash
# Pour traiter tous les fichiers JSON dans un dossier
for file in *.json; do
  output="${file%.json}.csv"
  node extract-json-to-csv.js "$file" "$output"
done

# Pour traiter plusieurs fichiers avec un filtre d'année
for file in *.json; do
  output="${file%.json}_2024.csv"
  node extract-json-to-csv.js "$file" "$output" 2024
done
```

> **Note pour Windows**: Si vous utilisez PowerShell, la syntaxe de la boucle est différente:
> ```powershell
> foreach ($file in Get-ChildItem -Filter "*.json") {
>   $output = $file.BaseName + ".csv"
>   node extract-json-to-csv.js $file.Name $output
> }
> ```

## Données extraites

Le script extrait les informations suivantes dans l'ordre:

1. reference (dernière transaction)
2. email du client
3. prénom
4. nom
5. date de naissance
6. montant du don
7. date de la transaction (format AAAA-MM-JJ)

## Licence

Ce script est fourni dans le cadre du logiciel Transibase 1.0.
© 2025 Québec Studio

Ce programme est un logiciel libre ; vous pouvez le redistribuer et/ou le modifier selon les termes de la Licence Publique Générale GNU publiée par la Free Software Foundation ; soit la version 3 de la licence, soit (à votre gré) toute version ultérieure.

Ce programme est distribué dans l'espoir qu'il sera utile, mais SANS AUCUNE GARANTIE ; sans même la garantie tacite de QUALITÉ MARCHANDE ou d'ADÉQUATION à UN BUT PARTICULIER. Consultez la Licence Publique Générale GNU pour plus de détails.

Vous devriez avoir reçu une copie de la Licence Publique Générale GNU avec ce programme ; si ce n'est pas le cas, consultez <https://www.gnu.org/licenses/licenses.fr.html>.

## Extraction des commandes depuis Craft CMS / Craft Commerce

Pour exporter les commandes de Craft Commerce au format JSON:

1. Connectez-vous au panneau d'administration de Craft CMS
2. Allez dans la section **Commerce** puis **Commandes**
3. Cliquez sur le bouton **Exporter...**
4. Dans les options d'exportation, choisissez:
   - **Type d'exportation** = Développé
   - **Format** = JSON
   - **Limite** = Aucune (ou choisissez une limite si nécessaire)
5. Cliquez sur **Exporter** pour télécharger le fichier JSON
6. Utilisez le fichier téléchargé comme entrée pour ce script

## Dépannage

- **Erreur "Le fichier JSON est mal formé"**: Vérifiez que votre fichier JSON est valide. Le script tente de réparer certains problèmes courants mais ne peut pas tout corriger.
- **Aucune transaction trouvée**: Si vous utilisez un filtre par année, vérifiez que des transactions existent pour cette année.
- **Erreur "module not found"**: Assurez-vous que Node.js est correctement installé.