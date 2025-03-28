# Dépannage

Ce document présente les problèmes courants que vous pourriez rencontrer lors de l'utilisation des scripts Transibase et propose des solutions.

## Table des matières

- [Problèmes généraux](#problèmes-généraux)
- [Problèmes d'encodage](#problèmes-dencoding)
- [Problèmes spécifiques aux environnements](#problèmes-spécifiques-aux-environnements)

## Problèmes généraux

### Le fichier JSON n'est pas trouvé

**Problème**: Le script indique que le fichier d'entrée n'existe pas.

**Solution**:
- Vérifiez le chemin du fichier et assurez-vous qu'il est correct
- Si le chemin comporte des espaces, entourez-le de guillemets
- Utilisez des chemins absolus plutôt que relatifs

### Aucune transaction trouvée

**Problème**: Le script s'exécute mais indique "Aucune transaction trouvée".

**Solution**:
- Vérifiez que le fichier JSON contient bien des données de transaction
- Si vous utilisez un filtre par année, vérifiez qu'il y a des transactions pour cette année
- Vérifiez que la structure du JSON correspond à celle attendue (voir [Format des fichiers](/doc/file-format.md))

### Format JSON invalide

**Problème**: Le script indique que le JSON est mal formé et ne peut pas être réparé automatiquement.

**Solution**:
- Vérifiez que votre fichier JSON est valide avec un validateur en ligne comme [JSONLint](https://jsonlint.com/)
- Assurez-vous que le fichier est bien encodé en UTF-8
- Si le fichier provient d'une exportation Craft Commerce, vérifiez que l'exportation a bien été complétée
- Essayez d'ouvrir le fichier dans un éditeur de texte et vérifiez s'il y a des caractères étranges ou incomplets

### Permission refusée lors de l'écriture du CSV

**Problème**: Le script ne peut pas créer ou écrire dans le fichier de sortie.

**Solution**:
- Vérifiez que vous avez les droits d'écriture dans le dossier de destination
- Fermez le fichier de sortie s'il est ouvert dans une autre application (comme Excel)
- Utilisez un chemin de destination où vous avez les permissions appropriées

## Problèmes d'encodage

### Caractères spéciaux mal affichés

**Problème**: Les caractères accentués ou spéciaux apparaissent incorrectement dans le fichier CSV.

**Solution**:
- Assurez-vous que votre fichier JSON d'entrée est encodé en UTF-8
- Ouvrez le fichier CSV avec un logiciel qui prend en charge l'UTF-8
- Si vous utilisez Excel, utilisez l'option d'importation de données et spécifiez l'encodage UTF-8

## Problèmes spécifiques aux environnements

### Node.js (JavaScript et TypeScript)

**Problème**: Erreur "Cannot find module 'ts-node'"

**Solution**:
- Installez ts-node globalement : `npm install -g ts-node`
- Ou localement dans votre projet : `npm install ts-node`

### Deno

**Problème**: Erreur de permissions pour la lecture/écriture de fichiers

**Solution**:
- Ajoutez les flags de permission appropriés : `deno run --allow-read --allow-write transibase_dgeq_convert_deno.ts ...`

### Bun

**Problème**: La commande "bun" n'est pas reconnue

**Solution**:
- Vérifiez que Bun est bien installé : `curl -fsSL https://bun.sh/install | bash`
- Assurez-vous que le chemin de Bun est dans votre PATH

### PHP

**Problème**: Erreur "PHP version must be >= 8.3.0"

**Solution**:
- Mettez à jour PHP vers la version 8.3 ou supérieure
- Sur Linux : `sudo add-apt-repository ppa:ondrej/php && sudo apt update && sudo apt install php8.3`
- Sur macOS : `brew update && brew install php`

**Problème**: Erreur lors de l'inclusion de `transibase_converter.php`

**Solution**:
- Vérifiez que ce fichier se trouve bien dans le même répertoire que votre script
- Si ce n'est pas le cas, ajustez le chemin dans le require_once

### Python

**Problème**: Erreur "SyntaxError" ou fonctionnalités non supportées

**Solution**:
- Le script nécessite Python 3.6 ou supérieur, Python 2 n'est pas supporté
- Vérifiez votre version avec `python --version` ou `python3 --version`
- Utilisez toujours la commande explicite pour Python 3 : `python3 transibase_dgeq_convert.py ...`
- Sur certains systèmes où Python 3 est l'installation par défaut, vous pouvez utiliser `python transibase_dgeq_convert.py ...`

### Go

**Problème**: Erreur de compilation ou "command not found"

**Solution**:
- Vérifiez que Go est bien installé : `go version`
- Assurez-vous d'avoir Go 1.16 ou supérieur pour les fonctionnalités utilisées
- Si vous compilez le script : `go build transibase_dgeq_convert.go`