# Guide Go

Ce document fournit des informations spécifiques sur l'utilisation de la version Go du script Transibase.

## Table des matières

- [Présentation de la version Go](#présentation-de-la-version-go)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Compilation](#compilation)
- [Performances](#performances)
- [Fonctionnalités spécifiques](#fonctionnalités-spécifiques)
- [Dépannage](#dépannage)

## Présentation de la version Go

La version Go du script Transibase est conçue pour tirer parti des forces du langage Go:
- Typage statique fort
- Performances élevées
- Compilation en binaire unique
- Exécution concurrente efficace
- Gestion robuste des erreurs

Elle est particulièrement utile si:
- Vous recherchez des performances optimales
- Vous préférez une solution compilée plutôt qu'interprétée
- Vous avez besoin d'un déploiement simple (fichier binaire unique)
- Vous travaillez avec de gros volumes de données

## Prérequis

- Go 1.16 ou supérieur
- Aucune dépendance externe n'est requise

## Installation

1. **Installer Go** si ce n'est pas déjà fait:
   - [Instructions d'installation Go](/doc/installation.md#go)

2. **Télécharger le script** dans votre répertoire de travail

3. **Vérifier l'installation**:
   ```bash
   go version
   ```
   Assurez-vous que la version est 1.16 ou supérieure.

## Utilisation

### Exécution directe (non compilée)

```bash
go run transibase_dgeq_convert.go <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Exemple:
```bash
go run transibase_dgeq_convert.go donnees.json rapport.csv 2023
```

### Traitement par lots

Pour traiter plusieurs fichiers JSON en une seule commande:

```bash
for file in *.json; do
  output="${file%.json}.csv"
  go run transibase_dgeq_convert.go "$file" "$output"
done
```

## Compilation

L'un des avantages majeurs de Go est la possibilité de compiler le script en un exécutable autonome.

### Compiler pour la plateforme courante

```bash
go build transibase_dgeq_convert.go
```

Cela génère un exécutable `transibase_dgeq_convert` (ou `transibase_dgeq_convert.exe` sous Windows) que vous pouvez exécuter directement:

```bash
./transibase_dgeq_convert <fichier_entrée.json> <fichier_sortie.csv> [année]
```

### Compilation multi-plateforme

Go permet la compilation croisée pour différentes plateformes:

```bash
# Pour Windows depuis Linux/macOS
GOOS=windows GOARCH=amd64 go build -o transibase_dgeq_convert.exe transibase_dgeq_convert.go

# Pour macOS depuis Linux/Windows
GOOS=darwin GOARCH=amd64 go build -o transibase_dgeq_convert_mac transibase_dgeq_convert.go

# Pour Linux depuis Windows/macOS
GOOS=linux GOARCH=amd64 go build -o transibase_dgeq_convert_linux transibase_dgeq_convert.go
```

### Distribution des exécutables

Les exécutables compilés peuvent être distribués et exécutés sur n'importe quelle machine de la même architecture sans installation préalable de Go ou d'autres dépendances.

## Performances

La version Go du script offre d'excellentes performances:

| Runtime | Taille du fichier | Temps de traitement |
|---------|------------------|---------------------|
| Node.js | 100 Mo           | ~2-3 secondes       |
| PHP     | 100 Mo           | ~4-5 secondes       |
| Python  | 100 Mo           | ~3-4 secondes       |
| Go      | 100 Mo           | ~0.5-1 seconde      |

Ces performances sont particulièrement avantageuses pour:
- Le traitement de gros fichiers JSON
- Le traitement par lots de nombreux fichiers
- Les environnements avec ressources limitées
- Les serveurs avec charge élevée

## Fonctionnalités spécifiques

### Avantages de la version Go

- **Performance**: Excellente vitesse d'exécution
- **Mémoire**: Gestion efficace de la mémoire
- **Portabilité**: Compilation en un seul binaire autonome
- **Types statiques**: Typage fort pour éviter les erreurs à l'exécution
- **Gestion des erreurs**: Gestion explicite des erreurs pour une meilleure robustesse
- **Multi-plateforme**: Fonctionne de façon identique sur toutes les plateformes

### Fonctionnalités du script

- Structure orientée objet avec types personnalisés
- Réparation automatique des JSON mal formés
- Gestion robuste des erreurs
- Filtrage par année des transactions
- Manipulation efficace des fichiers volumineux
- Échappement CSV conforme au standard RFC 4180
- Conversion automatique des formats de date

## Dépannage

### Problèmes courants

- **"go: command not found"**: Go n'est pas installé ou n'est pas dans le PATH. [Installez Go](/doc/installation.md#go) et assurez-vous qu'il est dans votre PATH.

- **Erreur de compilation**: Vérifiez que vous avez bien une version récente de Go avec `go version`. Le script nécessite Go 1.16 ou supérieur.

- **"cannot import..."**: Si vous avez modifié le script et rencontrez des erreurs d'importation, exécutez `go mod init transibase` puis `go mod tidy` pour gérer les dépendances.

- **"file not found"**: Vérifiez les chemins d'accès aux fichiers, surtout si vous utilisez des chemins relatifs.

### Solutions spécifiques

- **Problèmes de mémoire** (rares avec Go):
  ```bash
  # Augmenter la limite de mémoire pour la compilation
  GOGC=50 go build transibase_dgeq_convert.go
  ```

- **Optimiser les performances**:
  ```bash
  # Compiler avec optimisations
  go build -ldflags="-s -w" transibase_dgeq_convert.go
  ```

- **Déboguer le script**:
  ```bash
  # Ajouter des instructions de débogage
  go run -gcflags="-N -l" transibase_dgeq_convert.go
  ```

Pour plus d'informations sur le dépannage, consultez le [guide de dépannage général](/doc/troubleshooting.md).