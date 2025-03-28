# Guide Deno (TypeScript)

Ce document fournit des informations spécifiques sur l'utilisation de la version Deno du script Transibase.

## Table des matières

- [Présentation de Deno](#présentation-de-deno)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Sécurité et permissions](#sécurité-et-permissions)
- [Fonctionnalités spécifiques](#fonctionnalités-spécifiques)
- [Dépannage](#dépannage)

## Présentation de Deno

Deno est un runtime JavaScript et TypeScript moderne, créé par Ryan Dahl (également créateur de Node.js), avec une emphase sur la sécurité, la simplicité et les performances. Contrairement à Node.js, Deno:

- A un système de permissions explicites pour l'accès au système de fichiers, au réseau, etc.
- Prend en charge TypeScript nativement, sans configuration
- Utilise les modules ES (import/export) plutôt que CommonJS (require)
- Inclut un ensemble d'outils intégrés (formateur, linter, testeur, etc.)

## Prérequis

- Deno 1.0.0 ou supérieur

## Installation

1. **Installer Deno** si ce n'est pas déjà fait:
   - [Instructions d'installation Deno](/doc/installation.md#deno)

2. **Télécharger le script** dans votre répertoire de travail

3. **Vérifier l'installation**:
   ```bash
   deno --version
   ```

## Utilisation

### Exécution avec permissions explicites

```bash
deno run --allow-read --allow-write transibase_dgeq_convert_deno.ts <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Les flags de permission sont nécessaires:
- `--allow-read`: Permet au script de lire le fichier d'entrée
- `--allow-write`: Permet au script d'écrire le fichier de sortie

Exemple:
```bash
deno run --allow-read --allow-write transibase_dgeq_convert_deno.ts donnees.json rapport.csv 2023
```

### Rendre le script exécutable (Linux/macOS)

Pour une utilisation plus pratique sous Linux/macOS, vous pouvez rendre le script exécutable:

```bash
chmod +x transibase_dgeq_convert_deno.ts
```

Puis l'exécuter directement:
```bash
./transibase_dgeq_convert_deno.ts <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Le shebang au début du fichier `#!/usr/bin/env -S deno run --allow-read --allow-write` inclut automatiquement les permissions nécessaires.

## Sécurité et permissions

L'un des avantages de Deno est son modèle de sécurité par défaut. Le script Transibase ne nécessite que:

- `--allow-read`: Pour lire le fichier JSON d'entrée
- `--allow-write`: Pour écrire le fichier CSV de sortie

Vous pouvez restreindre davantage ces permissions en spécifiant exactement quels fichiers peuvent être lus/écrits:

```bash
deno run --allow-read=donnees.json --allow-write=rapport.csv transibase_dgeq_convert_deno.ts donnees.json rapport.csv
```

Cela empêche le script d'accéder à d'autres fichiers sur votre système.

## Fonctionnalités spécifiques

### Avantages de la version Deno

- **Sécurité renforcée**: Modèle de permissions explicites
- **TypeScript natif**: Pas de configuration ou compilation séparée nécessaire
- **Meilleures performances**: Généralement plus rapide que Node.js avec ts-node
- **Binaire unique**: Pas de dépendances externes à installer
- **Empreinte mémoire réduite**: Utilise moins de mémoire que Node.js

### Fonctionnalités du script

- Typage fort grâce à TypeScript
- Gestion asynchrone performante
- Réparation automatique des JSON mal formés
- Filtrage par année des transactions
- Conversion de divers formats de date

## Dépannage

### Problèmes courants

- **"PermissionDenied"**: Le script n'a pas les permissions nécessaires, assurez-vous d'utiliser `--allow-read` et `--allow-write`.
- **Erreur d'exécution du shebang**: Si le script exécutable ne fonctionne pas, vérifiez la ligne de shebang et assurez-vous que Deno est dans votre PATH.
- **"Not found"**: Le fichier d'entrée ou le chemin de sortie n'existe pas ou n'est pas accessible.

### Solutions spécifiques

- **Problèmes de version TypeScript**:
  ```bash
  # Forcer Deno à utiliser une version spécifique de TypeScript
  deno run --allow-read --allow-write --ts-version=4.9.5 transibase_dgeq_convert_deno.ts ...
  ```

- **Travailler hors ligne**:
  ```bash
  # Récupérer toutes les dépendances et les mettre en cache
  deno cache transibase_dgeq_convert_deno.ts
  
  # Puis exécuter sans accès réseau
  deno run --allow-read --allow-write --no-remote transibase_dgeq_convert_deno.ts ...
  ```

- **Déboguer le script**:
  ```bash
  deno run --allow-read --allow-write --inspect-brk transibase_dgeq_convert_deno.ts ...
  ```
  Puis ouvrez Chrome et accédez à `chrome://inspect` pour accéder au débogueur.

Pour plus d'informations sur le dépannage, consultez le [guide de dépannage général](/doc/troubleshooting.md).