# Traitement par lots

Ce document décrit comment traiter plusieurs fichiers JSON en une seule opération, en utilisant les différentes versions du script Transibase.

## Table des matières
- [Traitement sous Linux/macOS (Bash)](#traitement-sous-linuxmacos-bash)
- [Traitement sous Windows (PowerShell)](#traitement-sous-windows-powershell)
- [Traitement sous Windows (Batch)](#traitement-sous-windows-batch)
- [Automatisation et planification](#automatisation-et-planification)

## Traitement sous Linux/macOS (Bash)

### Traiter tous les fichiers JSON d'un dossier

Les exemples suivants traitent tous les fichiers JSON du dossier courant et génèrent un fichier CSV pour chacun.

#### Avec Node.js (JavaScript)

```bash
for file in *.json; do
  output="${file%.json}.csv"
  node transibase_dgeq_convert.js "$file" "$output"
done
```

#### Avec Node.js (TypeScript)

```bash
for file in *.json; do
  output="${file%.json}.csv"
  npx ts-node transibase_dgeq_convert_node.ts "$file" "$output"
done
```

#### Avec Deno

```bash
for file in *.json; do
  output="${file%.json}.csv"
  deno run --allow-read --allow-write transibase_dgeq_convert_deno.ts "$file" "$output"
done
```

#### Avec Bun

```bash
for file in *.json; do
  output="${file%.json}.csv"
  bun transibase_dgeq_convert_bun.ts "$file" "$output"
done
```

#### Avec PHP

```bash
for file in *.json; do
  output="${file%.json}.csv"
  php transibase_dgeq_convert.php "$file" "$output"
done
```

#### Avec Python

```bash
for file in *.json; do
  output="${file%.json}.csv"
  python3 transibase_dgeq_convert.py "$file" "$output"
done
```

### Traiter avec un filtre par année

Pour traiter tous les fichiers JSON mais ne garder que les transactions d'une année spécifique:

```bash
# Exemple avec Node.js (mais adaptable à tous les runtimes)
for file in *.json; do
  output="${file%.json}_2024.csv"
  node transibase_dgeq_convert.js "$file" "$output" 2024
done
```

### Traiter les fichiers d'un sous-dossier spécifique

```bash
# Exemple avec Python (mais adaptable à tous les runtimes)
for file in ./donnees/*.json; do
  filename=$(basename "$file")
  output="./rapports/${filename%.json}.csv"
  python3 transibase_dgeq_convert.py "$file" "$output"
done
```

## Traitement sous Windows (PowerShell)

### Traiter tous les fichiers JSON d'un dossier

#### Avec Node.js (JavaScript)

```powershell
foreach ($file in Get-ChildItem -Filter "*.json") {
  $output = $file.BaseName + ".csv"
  node transibase_dgeq_convert.js $file.Name $output
}
```

#### Avec Node.js (TypeScript)

```powershell
foreach ($file in Get-ChildItem -Filter "*.json") {
  $output = $file.BaseName + ".csv"
  npx ts-node transibase_dgeq_convert_node.ts $file.Name $output
}
```

#### Avec Bun (via WSL)

```powershell
foreach ($file in Get-ChildItem -Filter "*.json") {
  $output = $file.BaseName + ".csv"
  wsl bun ./transibase_dgeq_convert_bun.ts $file.Name $output
}
```

#### Avec PHP

```powershell
foreach ($file in Get-ChildItem -Filter "*.json") {
  $output = $file.BaseName + ".csv"
  php transibase_dgeq_convert.php $file.Name $output
}
```

#### Avec Python

```powershell
foreach ($file in Get-ChildItem -Filter "*.json") {
  $output = $file.BaseName + ".csv"
  python transibase_dgeq_convert.py $file.Name $output
}
```

### Traiter avec un filtre par année

```powershell
# Exemple avec Node.js (JavaScript)
foreach ($file in Get-ChildItem -Filter "*.json") {
  $output = $file.BaseName + "_2024.csv"
  node transibase_dgeq_convert.js $file.Name $output 2024
}
```

### Traiter des dossiers spécifiques

```powershell
# Exemple avec PHP
foreach ($file in Get-ChildItem -Path "C:\Données\JSON" -Filter "*.json") {
  $output = "C:\Rapports\" + $file.BaseName + ".csv"
  php transibase_dgeq_convert.php $file.FullName $output
}
```

## Traitement sous Windows (Batch)

Si vous préférez utiliser des fichiers batch (.bat) sous Windows:

```batch
@echo off
setlocal enabledelayedexpansion

REM Traiter tous les fichiers JSON du dossier courant
for %%f in (*.json) do (
  set "filename=%%~nf"
  echo Traitement de %%f...
  node transibase_dgeq_convert.js "%%f" "!filename!.csv"
)

echo Traitement terminé.
pause
```

## Automatisation et planification

### Sous Linux/macOS (Cron)

Pour exécuter le traitement automatiquement à intervalle régulier, vous pouvez utiliser cron:

1. Créez un script shell `process_donations.sh`:

```bash
#!/bin/bash

# Définir les chemins
INPUT_DIR="/home/user/donations/json"
OUTPUT_DIR="/home/user/donations/csv"
LOG_FILE="/home/user/donations/process.log"

# Créer le dossier de sortie si nécessaire
mkdir -p "$OUTPUT_DIR"

# Journaliser le début
echo "$(date): Début du traitement" >> "$LOG_FILE"

# Traiter tous les fichiers JSON
for file in "$INPUT_DIR"/*.json; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    output="$OUTPUT_DIR/${filename%.json}.csv"
    
    echo "$(date): Traitement de $filename" >> "$LOG_FILE"
    php transibase_dgeq_convert.php "$file" "$output" 2>> "$LOG_FILE"
  fi
done

echo "$(date): Fin du traitement" >> "$LOG_FILE"
```

2. Rendez le script exécutable:
```bash
chmod +x process_donations.sh
```

3. Configurez une tâche cron pour l'exécuter quotidiennement à 2h du matin:
```bash
crontab -e
```

4. Ajoutez la ligne suivante:
```
0 2 * * * /home/user/process_donations.sh
```

### Sous Windows (Planificateur de tâches)

1. Créez un script batch `process_donations.bat`:

```batch
@echo off
setlocal

REM Définir les chemins
set INPUT_DIR=C:\Donations\JSON
set OUTPUT_DIR=C:\Donations\CSV
set LOG_FILE=C:\Donations\process.log

REM Créer le dossier de sortie si nécessaire
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Journaliser le début
echo %date% %time%: Début du traitement >> "%LOG_FILE%"

REM Traiter tous les fichiers JSON
for %%f in ("%INPUT_DIR%\*.json") do (
  echo %date% %time%: Traitement de %%~nxf >> "%LOG_FILE%"
  node transibase_dgeq_convert.js "%%f" "%OUTPUT_DIR%\%%~nf.csv" 2>> "%LOG_FILE%"
)

echo %date% %time%: Fin du traitement >> "%LOG_FILE%"
```

2. Utilisez le Planificateur de tâches Windows:
   - Ouvrez "Planificateur de tâches" dans le Panneau de configuration
   - Créez une nouvelle tâche de base
   - Configurez-la pour qu'elle s'exécute quotidiennement
   - Définissez l'action pour démarrer un programme
   - Parcourez jusqu'à votre script batch
   - Terminez la configuration de la tâche