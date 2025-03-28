# Dépannage

Ce document présente les problèmes courants que vous pourriez rencontrer lors de l'utilisation des scripts Transibase et propose des solutions.

## Table des matières

- [Problèmes généraux](#problèmes-généraux)
- [Node.js (JavaScript et TypeScript)](#nodejs-javascript-et-typescript)
- [Deno](#deno)
- [Bun](#bun)
- [PHP](#php)
- [Python](#python)
- [Problèmes de format](#problèmes-de-format)

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

### Problèmes d'encodage des caractères spéciaux

**Problème**: Les caractères accentués ou spéciaux apparaissent incorrectement dans le fichier CSV.

**Solution**:
- Assurez-vous que votre fichier JSON d'entrée est encodé en UTF-8
- Ouvrez le fichier CSV avec un logiciel qui prend en charge l'UTF-8
- Si vous utilisez Excel, utilisez l'option d'importation de données et spécifiez l'encodage UTF-8