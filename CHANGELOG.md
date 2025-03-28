# Changelog

Toutes les modifications notables apportées à ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-03-28

### Ajouts
- Version initiale du script d'extraction JSON vers CSV pour le DGEQ
- Implémentations multiples:
  - JavaScript pour Node.js
  - TypeScript pour Node.js
  - TypeScript pour Deno
  - TypeScript pour Bun
  - PHP 8.3+
  - Python 3.x
- Filtrage des transactions par année
- Prise en charge des formats de date multiples
- Tentative de réparation automatique des JSON mal formés
- Documentation complète avec exemples
- Fichier exemple anonymisé pour tests

### Fonctionnalités
- Extraction des références de transactions
- Extraction des emails des clients
- Extraction des données personnelles (prénom, nom, date de naissance)
- Extraction des montants de donation
- Extraction des dates de transaction
- Formatage des données en CSV (tous les champs entre guillemets doubles)
- Option de filtrage par année
- Gestion des erreurs et validation des entrées
- Scripts compatibles pour traitement par lots
- Version PHP avec séparation en deux fichiers:
  - `transibase_converter.php`: Classes et logique de conversion
  - `transibase_dgeq_convert.php`: Interface en ligne de commande

### Notes techniques
- Format CSV conforme au standard RFC 4180
- Détection et conversion automatique des formats de date
- Gestion unifiée des structures JSON imbriquées
- Compatible avec les environnements modernes (ES6+, Python 3.6+, PHP 8.3+)
- Fonctionnement similaire et résultats identiques entre toutes les versions