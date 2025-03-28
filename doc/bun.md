# Guide Bun (TypeScript)

Ce document fournit des informations spécifiques sur l'utilisation de la version Bun du script Transibase.

## Table des matières

- [Présentation de Bun](#présentation-de-bun)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Performances](#performances)
- [Utilisation sous Windows](#utilisation-sous-windows)
- [Fonctionnalités spécifiques](#fonctionnalités-spécifiques)
- [Dépannage](#dépannage)

## Présentation de Bun

Bun est un runtime JavaScript tout-en-un, conçu comme une alternative moderne à Node.js. Ses principales caractéristiques:

- **Performances ultrarapides**: Jusqu'à 3 fois plus rapide que Node.js
- **TypeScript intégré**: Support natif de TypeScript sans configuration
- **Tout-en-un**: Bundler, test runner, gestionnaire de packages intégrés
- **Compatible Node.js**: API compatible avec la plupart des modules Node.js
- **Empreinte mémoire réduite**: Utilise moins de mémoire que Node.js ou Deno

## Prérequis

- Bun 1.0.0 ou supérieur
- Sous Windows: WSL (Windows Subsystem for Linux)

## Installation

1. **Installer Bun** si ce n'est pas déjà fait:
   - [Instructions d'installation Bun](/doc/installation.md#bun)

2. **Télécharger le script** dans votre répertoire de travail

3. **Vérifier l'installation**:
   ```bash
   bun --version
   ```

## Utilisation

### Exécution standard

```bash
bun transibase_dgeq_convert_bun.ts <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Exemple:
```bash
bun transibase_dgeq_convert_bun.ts donnees.json rapport.csv 2023
```

### Rendre le script exécutable (Linux/macOS)

Pour une utilisation plus pratique sous Linux/macOS, vous pouvez rendre le script exécutable:

```bash
chmod +x transibase_dgeq_convert_bun.ts
```

Puis l'exécuter directement:
```bash
./transibase_dgeq_convert_bun.ts <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Le shebang au début du fichier `#!/usr/bin/env bun` permet cette exécution directe.

### Traitement par lots

Pour traiter plusieurs fichiers JSON en une seule commande:

```bash
for file in *.json; do
  output="${file%.json}.csv"
  bun transibase_dgeq_convert_bun.ts "$file" "$output"
done
```

## Performances

La version Bun du script offre des performances significativement améliorées:

| Runtime | Taille du fichier | Temps de traitement |
|---------|------------------|---------------------|
| Node.js | 100 Mo           | ~2-3 secondes       |
| Deno    | 100 Mo           | ~1-2 secondes       |
| Bun     | 100 Mo           | ~0.5-1 seconde      |

Ces performances sont particulièrement avantageuses pour:
- Le traitement de gros fichiers JSON
- Le traitement par lots de nombreux fichiers
- Les environnements avec ressources limitées

## Utilisation sous Windows

Bun n'est pas directement supporté sous Windows, mais peut être utilisé via WSL (Windows Subsystem for Linux):

1. **Installer WSL si ce n'est pas déjà fait**:
   ```powershell
   wsl --install
   ```

2. **Ouvrir un terminal WSL** (Ubuntu par défaut)

3. **Installer Bun dans l'environnement WSL**:
   ```bash
   curl -fsSL https://bun.sh/install | bash
   ```

4. **Utiliser le script depuis WSL**:
   ```bash
   bun transibase_dgeq_convert_bun.ts <fichier_entrée.json> <fichier_sortie.csv> [année]
   ```

### Accéder aux fichiers Windows depuis WSL

Pour traiter des fichiers situés sur le système de fichiers Windows:

```bash
# Les lecteurs Windows sont montés sous /mnt dans WSL
bun transibase_dgeq_convert_bun.ts /mnt/c/Users/VotreNom/Documents/donnees.json /mnt/c/Users/VotreNom/Documents/rapport.csv
```

## Fonctionnalités spécifiques

### Avantages de la version Bun

- **Performances supérieures**: Le plus rapide de tous les runtimes
- **Empreinte mémoire réduite**: Utilise moins de mémoire
- **TypeScript natif**: Pas de configuration ou compilation séparée nécessaire
- **Compatible Node.js**: Utilise les mêmes APIs que Node.js
- **Démarrage quasi instantané**: Temps de démarrage minimal

### Fonctionnalités du script

- Typage fort grâce à TypeScript
- Réparation automatique des JSON mal formés
- Filtrage par année des transactions
- Manipulation efficace des objets JSON volumineux
- Interaction avec l'utilisateur pour confirmer l'écrasement des fichiers

## Dépannage

### Problèmes courants

- **"Command not found: bun"**: Bun n'est pas installé ou n'est pas dans le PATH. Réinstallez-le avec `curl -fsSL https://bun.sh/install | bash`.

- **Erreurs sous Windows**: Assurez-vous d'utiliser WSL, Bun ne fonctionne pas nativement sous Windows.

- **"EACCES: permission denied"**: Le script n'a pas les permissions nécessaires. Utilisez `chmod +x` pour le rendre exécutable.

- **Incompatibilité avec certains modules Node.js**: Bien que Bun soit compatible avec la plupart des modules Node.js, certains modules très spécifiques peuvent ne pas fonctionner comme prévu.

### Solutions spécifiques

- **Problèmes de mémoire** (rare avec Bun):
  ```bash
  # Augmenter la mémoire disponible pour Bun
  BUN_MEMORY=4096 bun transibase_dgeq_convert_bun.ts ...
  ```

- **Forcer la compatibilité Node.js**:
  ```bash
  # Activer le mode de compatibilité strict
  bun --compat transibase_dgeq_convert_bun.ts ...
  ```

- **Déboguer le script**:
  ```bash
  bun --inspect transibase_dgeq_convert_bun.ts ...
  ```
  Puis ouvrez Chrome et accédez à `chrome://inspect` pour accéder au débogueur.

Pour plus d'informations sur le dépannage, consultez le [guide de dépannage général](/doc/troubleshooting.md).