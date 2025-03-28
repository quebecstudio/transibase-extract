# Guide Node.js (JavaScript/TypeScript)

Ce document fournit des informations spécifiques sur l'utilisation des versions Node.js du script Transibase, disponibles en JavaScript et TypeScript.

## Table des matières

- [Versions disponibles](#versions-disponibles)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Fonctionnalités spécifiques](#fonctionnalités-spécifiques)
- [Performances](#performances)
- [Dépannage](#dépannage)

## Versions disponibles

Deux versions du script sont disponibles pour Node.js:

1. **JavaScript**: `transibase_dgeq_convert.js`
   - Version standard utilisant la syntaxe JavaScript moderne (ES6+)
   - Ne nécessite que Node.js

2. **TypeScript**: `transibase_dgeq_convert_node.ts`
   - Version avec typage statique
   - Nécessite Node.js et TypeScript/ts-node

## Prérequis

### Pour la version JavaScript

- Node.js 14.0.0 ou supérieur

### Pour la version TypeScript

- Node.js 14.0.0 ou supérieur
- TypeScript 4.0.0 ou supérieur
- ts-node (pour exécution directe sans compilation préalable)

## Installation

1. **Installer Node.js** si ce n'est pas déjà fait:
   - [Instructions d'installation Node.js](/doc/installation.md#nodejs)

2. **Pour la version TypeScript**, installer TypeScript et ts-node:
   ```bash
   npm install -g typescript ts-node
   ```

3. **Télécharger les scripts** dans votre répertoire de travail

## Utilisation

### Version JavaScript

```bash
node transibase_dgeq_convert.js <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Exemple:
```bash
node transibase_dgeq_convert.js donnees.json rapport.csv 2023
```

### Version TypeScript

#### Exécution directe avec ts-node

```bash
npx ts-node transibase_dgeq_convert_node.ts <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Exemple:
```bash
npx ts-node transibase_dgeq_convert_node.ts donnees.json rapport.csv 2023
```

#### Compilation puis exécution

```bash
# Compiler le TypeScript en JavaScript
npx tsc transibase_dgeq_convert_node.ts

# Exécuter le fichier JavaScript généré
node transibase_dgeq_convert_node.js <fichier_entrée.json> <fichier_sortie.csv> [année]
```

## Fonctionnalités spécifiques

### Avantages de la version JavaScript

- **Simplicité**: Pas besoin d'étape de compilation
- **Compatibilité**: Fonctionne sur toute installation Node.js standard
- **Taille réduite**: Fichier plus léger

### Avantages de la version TypeScript

- **Typage statique**: Détection d'erreurs potentielles à la compilation
- **Meilleure autocomplétion**: Dans les éditeurs de code compatibles (VS Code, etc.)
- **Documentation intégrée**: Les types servent de documentation
- **Maintenance facilité**: Plus clair pour les modifications futures

### Fonctionnalités communes

Les deux versions offrent:
- Réparation automatique des JSON mal formés
- Conversion de formats de date variés
- Filtrage par année
- Gestion des caractères spéciaux dans le CSV

## Performances

Les performances des deux versions sont similaires:

- **JavaScript**: Légèrement plus rapide car sans étape de compilation
- **TypeScript**: Performance équivalente une fois compilé

Pour des fichiers de grande taille (>100 Mo), considérez:
- Augmenter la mémoire disponible pour Node.js: `node --max-old-space-size=4096 transibase_dgeq_convert.js ...`
- Utiliser la version JavaScript pour un traitement légèrement plus rapide

## Dépannage

### Problèmes courants avec la version JavaScript

- **"SyntaxError: Unexpected token ..."**: Votre version de Node.js est trop ancienne, mettez à jour vers une version plus récente.
- **"ReferenceError: Cannot access '...' before initialization"**: Même problème, version de Node.js trop ancienne.

### Problèmes courants avec la version TypeScript

- **"Cannot find module 'typescript'"**: TypeScript n'est pas installé, exécutez `npm install -g typescript`.
- **"Cannot find module 'ts-node'"**: ts-node n'est pas installé, exécutez `npm install -g ts-node`.
- **Erreurs de type**: Le fichier TypeScript contient des erreurs de typage qui doivent être corrigées.

### Problèmes généraux

- **"Error: Cannot find module 'fs'"**: Votre environnement Node.js est incomplet.
- **Problèmes de mémoire pour les gros fichiers**: Utilisez l'option `--max-old-space-size`:
  ```bash
  node --max-old-space-size=4096 transibase_dgeq_convert.js fichier_volumineux.json sortie.csv
  ```

Pour plus d'informations sur le dépannage, consultez le [guide de dépannage général](/doc/troubleshooting.md).