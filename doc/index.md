# Documentation Transibase 1.0

Bienvenue dans la documentation du projet Transibase, un outil d'extraction de données JSON vers CSV pour les rapports financiers du DGEQ.

## Structure de la documentation

- [Installation](installation.md) - Comment installer les prérequis
- [Utilisation](usage.md) - Guide d'utilisation général
- [Traitement par lots](batch-processing.md) - Traitement de multiples fichiers
- [Format des fichiers](file-format.md) - Détails sur les formats d'entrée/sortie
- [Dépannage](troubleshooting.md) - Solutions aux problèmes courants

## Guides spécifiques par environnement

- [Node.js](node.md) - Guide pour les versions JavaScript et TypeScript Node.js
- [Deno](deno.md) - Guide pour la version TypeScript Deno
- [Bun](bun.md) - Guide pour la version TypeScript Bun
- [PHP](php.md) - Guide pour la version PHP 8.3+
- [Python](python.md) - Guide pour la version Python 3.x
- [Go](go.md) - Guide pour la version Go

## Tableau comparatif des versions

| Caractéristique | Node.js (JS) | Node.js (TS) | Deno | Bun | PHP | Python | Go |
|-----------------|--------------|--------------|------|-----|-----|--------|-----|
| **Langage** | JavaScript | TypeScript | TypeScript | TypeScript | PHP 8.3+ | Python 3.x | Go |
| **Performance** | Bonne | Bonne | Meilleure | Excellente | Correcte | Bonne | Excellente |
| **Typage** | Non | Oui | Oui | Oui | Oui | Non | Oui |
| **Dépendances externes** | Non | TypeScript, ts-node | Non | Non | Non | Non | Non |
| **Portabilité** | Très bonne | Très bonne | Très bonne | Moyenne* | Très bonne | Excellente | Excellente |
| **Sécurité** | Standard | Standard | Renforcée | Standard | Standard | Standard | Renforcée |
| **Disponibilité** | À installer | À installer | À installer | À installer | Souvent préinstallé | Souvent préinstallé | À installer |
| **Intégration web** | Possible | Possible | Possible | Possible | Excellente | Possible | Excellente |
| **Facilité d'utilisation** | Simple | Moyenne | Simple | Simple | Simple | Très simple | Moyenne |
| **Déploiement** | Interprété | Interprété | Interprété | Interprété | Interprété | Interprété | Compilé |

\* Bun a une compatibilité limitée avec Windows (via WSL uniquement)

## Choix de la version

Pour vous aider à choisir la version qui convient le mieux à votre cas d'utilisation:

### Choisissez Node.js (JavaScript) si:
- Vous êtes familier avec JavaScript
- Vous cherchez une solution simple sans compilation
- Vous avez déjà Node.js installé

### Choisissez Node.js (TypeScript) si:
- Vous préférez le typage statique
- Vous utilisez TypeScript pour d'autres projets
- Vous accordez de l'importance à la maintenabilité

### Choisissez Deno si:
- Vous préférez un modèle de sécurité plus strict
- Vous aimez TypeScript sans configuration
- Vous appréciez un runtime moderne et tout-en-un

### Choisissez Bun si:
- Vous recherchez des performances maximales
- Vous utilisez déjà Bun pour d'autres projets
- Vous n'avez pas besoin de compatibilité Windows native

### Choisissez PHP si:
- Vous travaillez dans un environnement web
- PHP est la seule option disponible sur votre hébergement
- Vous souhaitez intégrer la fonctionnalité à une application web existante

### Choisissez Python si:
- Vous êtes plus à l'aise avec Python
- Python est déjà installé sur votre système
- Vous préférez une solution qui fonctionne partout sans installation

### Choisissez Go si:
- Vous recherchez des performances élevées
- Vous préférez une application compilée avec un déploiement simple
- Vous appréciez la portabilité entre différentes plateformes
- Vous valorisez la sécurité mémoire et le typage fort

## Contribuer à la documentation

Cette documentation est contenue dans le dossier `/doc` du projet. Pour suggérer des améliorations ou signaler des erreurs, veuillez créer une issue ou une pull request sur le dépôt du projet.