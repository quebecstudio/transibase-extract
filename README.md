# Transibase 1.0 - Extracteur JSON vers CSV

Ce script fait partie du logiciel Transibase 1.0 développé par Québec Studio.
Il permet d'extraire des données spécifiques à partir de fichiers JSON de commandes Craft Commerce et de les exporter dans un format CSV.

## Soutien à l'Ukraine et appel à la solidarité 🇺🇦

Québec Studio soutient l'Ukraine et son peuple dans sa quête de paix, de liberté et de souveraineté.

Si vous ne soutenez pas le peuple ukrainien dans cette guerre injuste qu'il n'a jamais souhaitée, nous vous demandons de ne pas utiliser nos logiciels, car ils sont destinés à ceux qui souhaitent être du bon côté de l'histoire.

## Objectif

Ce script est conçu pour générer le document à fournir au Directeur général des élections du Québec (DGEQ) pour les partis municipaux. Le fichier CSV généré contient les données minimales requises par le DGEQ pour la conformité des rapports financiers des partis politiques municipaux.

## Versions disponibles

Deux versions du script sont disponibles:

1. **Version Node.js** (`transibase_dgeq_convert.js`) - nécessite Node.js
2. **Version Python** (`transibase_dgeq_convert.py`) - nécessite Python 3.x

Choisissez la version qui correspond le mieux à votre environnement.

## Prérequis

### Option 1: Node.js

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

### Option 2: Python

Python est préinstallé sur la plupart des systèmes macOS et Linux. Pour Windows, suivez ces étapes:

#### Sur Windows (PC)

1. **Télécharger l'installateur**
   - Allez sur le site officiel de Python : https://www.python.org/downloads/
   - Téléchargez la dernière version de Python 3.x
   
2. **Installer Python**
   - Exécutez le fichier .exe téléchargé
   - **Important**: Cochez la case "Add Python to PATH" avant de cliquer sur "Install Now"
   
3. **Vérifier l'installation**
   - Ouvrez l'invite de commande (cmd) ou PowerShell
   - Tapez la commande suivante:
   ```
   python --version
   ```
   - Si cela ne fonctionne pas, essayez:
   ```
   py --version
   ```

#### Sur macOS

La plupart des systèmes macOS ont déjà Python installé. Pour vérifier et installer si nécessaire:

1. **Vérifier l'installation**
   - Ouvrez le Terminal
   - Tapez:
   ```
   python3 --version
   ```

2. **Si Python n'est pas installé**:
   - Utilisez Homebrew:
   ```
   brew install python
   ```
   - Ou téléchargez l'installateur depuis https://www.python.org/downloads/macos/

#### Sur Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install python3 python3-pip
```

## Utilisation du script

### Utilisation de la version Node.js

```bash
# Utilisation basique
node transibase_dgeq_convert.js input.json output.csv

# Avec filtrage par année (seulement les transactions de 2024)
node transibase_dgeq_convert.js input.json output.csv 2024
```

### Utilisation de la version Python

```bash
# Rendre le script exécutable (Linux/macOS uniquement)
chmod +x transibase_dgeq_convert.py

# Utilisation basique
python transibase_dgeq_convert.py input.json output.csv
# ou directement (Linux/macOS)
./transibase_dgeq_convert.py input.json output.csv

# Avec filtrage par année (seulement les transactions de 2024)
python transibase_dgeq_convert.py input.json output.csv 2024
```

Si le fichier de sortie existe déjà, le script vous demandera si vous souhaitez l'écraser.

### Traitement par lots

#### Avec Node.js

```bash
# Pour traiter tous les fichiers JSON dans un dossier
for file in *.json; do
  output="${file%.json}.csv"
  node transibase_dgeq_convert.js "$file" "$output"
done

# Pour traiter plusieurs fichiers avec un filtre d'année
for file in *.json; do
  output="${file%.json}_2024.csv"
  node transibase_dgeq_convert.js "$file" "$output" 2024
done
```

#### Avec Python

```bash
# Pour traiter tous les fichiers JSON dans un dossier
for file in *.json; do
  output="${file%.json}.csv"
  python transibase_dgeq_convert.py "$file" "$output"
done

# Pour traiter plusieurs fichiers avec un filtre d'année
for file in *.json; do
  output="${file%.json}_2024.csv"
  python transibase_dgeq_convert.py "$file" "$output" 2024
done
```

> **Note pour Windows**: Si vous utilisez PowerShell, la syntaxe de la boucle est différente:
> ```powershell
> # Version Node.js
> foreach ($file in Get-ChildItem -Filter "*.json") {
>   $output = $file.BaseName + ".csv"
>   node transibase_dgeq_convert.js $file.Name $output
> }
>
> # Version Python
> foreach ($file in Get-ChildItem -Filter "*.json") {
>   $output = $file.BaseName + ".csv"
>   python transibase_dgeq_convert.py $file.Name $output
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

### Problèmes courants avec la version Node.js

- **Erreur "module not found"**: Assurez-vous que Node.js est correctement installé.
- **Erreur "Le fichier JSON est mal formé"**: Vérifiez que votre fichier JSON est valide.
- **Aucune transaction trouvée**: Si vous utilisez un filtre par année, vérifiez que des transactions existent pour cette année.

### Problèmes courants avec la version Python

- **Erreur "python not found"**: Sur Windows, essayez d'utiliser `py` au lieu de `python`. Sur macOS/Linux, utilisez `python3`.
- **Erreur "JSONDecodeError"**: Vérifiez que votre fichier JSON est correctement formaté.
- **Erreur "Permission denied"**: Sur Linux/macOS, assurez-vous que le script est exécutable avec `chmod +x transibase_dgeq_convert.py`.

## Licence

Ce script est fourni dans le cadre du logiciel Transibase 1.0.
© 2025 Québec Studio

Ce programme est un logiciel libre ; vous pouvez le redistribuer et/ou le modifier selon les termes de la Licence Publique Générale GNU publiée par la Free Software Foundation ; soit la version 3 de la licence, soit (à votre gré) toute version ultérieure.

Ce programme est distribué dans l'espoir qu'il sera utile, mais SANS AUCUNE GARANTIE ; sans même la garantie tacite de QUALITÉ MARCHANDE ou d'ADÉQUATION à UN BUT PARTICULIER. Consultez la Licence Publique Générale GNU pour plus de détails.

Vous devriez avoir reçu une copie de la Licence Publique Générale GNU avec ce programme ; si ce n'est pas le cas, consultez <https://www.gnu.org/licenses/licenses.fr.html>.