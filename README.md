# Transibase 1.0 - Extracteur JSON vers CSV

Ce script fait partie du logiciel Transibase 1.0 développé par Québec Studio.
Il permet d'extraire des données spécifiques à partir de fichiers JSON de commandes Craft Commerce et de les exporter dans un format CSV conforme aux exigences du DGEQ.

## Soutien à l'Ukraine et appel à la solidarité 🇺🇦

Québec Studio soutient l'Ukraine et son peuple dans sa quête de paix, de liberté et de souveraineté.

Si vous ne soutenez pas le peuple ukrainien dans cette guerre injuste qu'il n'a jamais souhaitée, nous vous demandons de ne pas utiliser nos logiciels, car ils sont destinés à ceux qui souhaitent être du bon côté de l'histoire.

## Objectif

Ce script est conçu pour générer le document à fournir au Directeur général des élections du Québec (DGEQ) pour les partis municipaux. Le fichier CSV généré contient les données minimales requises par le DGEQ pour la conformité des rapports financiers des partis politiques municipaux.

## Versions disponibles

Plusieurs implémentations sont disponibles pour s'adapter à différents environnements:

| Langage | Environnement | Fichier |
|---------|---------------|---------|
| JavaScript | Node.js | `transibase_dgeq_convert.js` |
| TypeScript | Node.js | `transibase_dgeq_convert_node.ts` |
| TypeScript | Deno | `transibase_dgeq_convert_deno.ts` |
| TypeScript | Bun | `transibase_dgeq_convert_bun.ts` |
| PHP 8.3+ | CLI/Web | `transibase_dgeq_convert.php` & `transibase_converter.php` |
| Python 3.x | | `transibase_dgeq_convert.py` |

> **Note**: La version PHP est composée de deux fichiers : un pour les classes et la logique de conversion (`transibase_converter.php`), et un pour l'interface en ligne de commande (`transibase_dgeq_convert.php`). Cette structure facilite l'intégration dans des applications web existantes.

## Utilisation rapide

```bash
# Node.js (JavaScript)
node transibase_dgeq_convert.js input.json output.csv [année]

# Node.js (TypeScript)
npx ts-node transibase_dgeq_convert_node.ts input.json output.csv [année]

# Deno
deno run --allow-read --allow-write transibase_dgeq_convert_deno.ts input.json output.csv [année]

# Bun
bun transibase_dgeq_convert_bun.ts input.json output.csv [année]

# PHP
php transibase_dgeq_convert.php input.json output.csv [année]

# Python
python3 transibase_dgeq_convert.py input.json output.csv [année]
```

## Données extraites

Le script extrait les informations suivantes:
- Référence de transaction
- Email du client
- Prénom et nom
- Date de naissance
- Montant du don
- Date de la transaction

## Documentation détaillée

Pour une documentation complète, consultez le fichier [index](/doc/index.md) dans le dossier `/doc`.

- [Installation](/doc/installation.md) - Instructions d'installation détaillées
- [Utilisation](/doc/usage.md) - Guide d'utilisation complet
- [Traitement par lots](/doc/batch-processing.md) - Traitement de multiples fichiers
- [Dépannage](/doc/troubleshooting.md) - Solutions aux problèmes courants
- [Format des fichiers](/doc/file-format.md) - Détails sur les formats d'entrée/sortie
- Guides spécifiques: [Node.js](/doc/node.md), [Deno](/doc/deno.md), [Bun](/doc/bun.md), [PHP](/doc/php.md), [Python](/doc/python.md)

## Licence

Ce script est fourni dans le cadre du logiciel Transibase 1.0.
© 2025 Québec Studio

Ce programme est un logiciel libre ; vous pouvez le redistribuer et/ou le modifier selon les termes de la Licence Publique Générale GNU publiée par la Free Software Foundation (version 3 ou ultérieure).

[Voir le texte complet de la licence](/LICENSE)