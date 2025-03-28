# Guide Python

Ce document fournit des informations spécifiques sur l'utilisation de la version Python du script Transibase.

## Table des matières

- [Présentation de la version Python](#présentation-de-la-version-python)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Compatibilité Python](#compatibilité-python)
- [Fonctionnalités spécifiques](#fonctionnalités-spécifiques)
- [Dépannage](#dépannage)

## Présentation de la version Python

La version Python du script Transibase (`transibase_dgeq_convert.py`) offre une solution robuste et portable, utilisant uniquement des modules standards de la bibliothèque Python. Elle est particulièrement adaptée pour:

- Les utilisateurs habitués à l'écosystème Python
- Les environnements où Python est déjà installé (la plupart des systèmes Linux/macOS)
- Ceux qui préfèrent la clarté et la lisibilité du code Python

## Prérequis

- Python 3.6 ou supérieur
- Aucun module externe n'est nécessaire, le script n'utilise que des modules standards

## Installation

1. **Vérifier l'installation de Python**:
   ```bash
   python3 --version
   ```
   Sur Windows, vous pouvez utiliser `python --version` ou `py --version`.

2. **Installer Python** si ce n'est pas déjà fait:
   - [Instructions d'installation Python](/doc/installation.md#python-3)

3. **Télécharger le script** dans votre répertoire de travail

## Utilisation

### Exécution standard

```bash
# Sur Linux/macOS
python3 transibase_dgeq_convert.py <fichier_entrée.json> <fichier_sortie.csv> [année]

# Sur Windows
python transibase_dgeq_convert.py <fichier_entrée.json> <fichier_sortie.csv> [année]
# ou
py transibase_dgeq_convert.py <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Exemple:
```bash
python3 transibase_dgeq_convert.py donnees.json rapport.csv 2023
```

### Rendre le script exécutable (Linux/macOS)

Pour une utilisation plus pratique sous Linux/macOS, vous pouvez rendre le script exécutable:

```bash
chmod +x transibase_dgeq_convert.py
```

Puis l'exécuter directement:
```bash
./transibase_dgeq_convert.py <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Le shebang au début du fichier `#!/usr/bin/env python3` permet cette exécution directe.

### Traitement par lots

Pour traiter plusieurs fichiers JSON en une seule commande:

```bash
# Sur Linux/macOS
for file in *.json; do
  output="${file%.json}.csv"
  python3 transibase_dgeq_convert.py "$file" "$output"
done

# Sur Windows (PowerShell)
foreach ($file in Get-ChildItem -Filter "*.json") {
  $output = $file.BaseName + ".csv"
  python transibase_dgeq_convert.py $file.Name $output
}
```

## Compatibilité Python

Le script est compatible avec différentes versions de Python:

| Version Python | Compatibilité | Notes |
|----------------|---------------|-------|
| Python 3.6+    | ✅ Complète   | Version recommandée |
| Python 3.0-3.5 | ⚠️ Partielle  | Peut nécessiter des modifications mineures |
| Python 2.7     | ❌ Non supporté | Nécessiterait des modifications importantes |

### Adaptations pour versions plus anciennes

Si vous devez utiliser une version de Python antérieure à 3.6:

1. Remplacez les f-strings par la méthode `.format()`:
   - Exemple: `f"Erreur: {error}"` devient `"Erreur: {}".format(error)`

2. Remplacer l'utilisation de la syntaxe d'accès avec l'opérateur `??`:
   - Exemple: `item.get('customer', {}).get('email', '')` au lieu de `item['customer']?.['email']`

## Fonctionnalités spécifiques

### Avantages de la version Python

- **Portabilité**: Fonctionne sur pratiquement tous les systèmes d'exploitation
- **Lisibilité**: Syntaxe Python claire et expressive
- **Aucune dépendance externe**: Utilise uniquement des modules standards
- **Disponibilité**: Python est préinstallé sur la plupart des systèmes Unix

### Fonctionnalités du script

- Détection et conversion automatique de multiples formats de date
- Réparation automatique des JSON mal formés
- Filtrage par année des transactions
- Gestion robuste des structures JSON imbriquées
- Support multilingue avec encodage UTF-8

## Dépannage

### Problèmes courants

- **"python: command not found"**: Sur Linux/macOS, utilisez `python3` au lieu de `python`.

- **"No module named..."**: Ce message ne devrait pas apparaître car le script n'utilise que des modules standards. Si vous le voyez, votre installation Python pourrait être incomplète.

- **Problèmes d'encodage**: Si vous rencontrez des problèmes avec les caractères accentués:
  ```bash
  # Forcer l'encodage UTF-8
  PYTHONIOENCODING=utf-8 python3 transibase_dgeq_convert.py ...
  ```

- **"JSONDecodeError"**: Le fichier JSON d'entrée est probablement mal formé et ne peut pas être réparé automatiquement.

### Solutions spécifiques

- **Problèmes de mémoire pour gros fichiers**:
  Le script Python gère généralement bien les fichiers volumineux grâce au traitement itératif. Si vous rencontrez des problèmes de mémoire:
  ```bash
  # Augmenter la limite de récursion
  python3 -X faulthandler transibase_dgeq_convert.py ...
  ```

- **Débogage**:
  ```bash
  # Activer les messages de débogage
  python3 -d transibase_dgeq_convert.py ...
  ```

- **Problèmes de versions Python**:
  Si vous avez plusieurs versions de Python installées, spécifiez explicitement la version:
  ```bash
  python3.9 transibase_dgeq_convert.py ...
  ```

Pour plus d'informations sur le dépannage, consultez le [guide de dépannage général](/doc/troubleshooting.md).