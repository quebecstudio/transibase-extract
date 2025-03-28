# Guide PHP

Ce document fournit des informations spécifiques sur l'utilisation de la version PHP du script Transibase.

## Table des matières

- [Présentation de la version PHP](#présentation-de-la-version-php)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Utilisation sur un serveur web](#utilisation-sur-un-serveur-web)
- [Fonctionnalités spécifiques](#fonctionnalités-spécifiques)
- [Dépannage](#dépannage)

## Présentation de la version PHP

La version PHP du script Transibase est conçue pour tirer parti des fonctionnalités modernes de PHP 8.3+:
- Programmation orientée objet
- Typage strict
- Gestion des exceptions
- Fonctionnalités récentes de PHP (str_contains, null coalescing, etc.)

Elle est particulièrement utile si:
- Vous travaillez déjà dans un environnement PHP
- Vous souhaitez intégrer la fonctionnalité à une application web existante
- PHP est la seule option disponible sur votre hébergement

## Prérequis

- PHP 8.3 ou supérieur
- Extensions PHP: json (généralement activée par défaut)

## Installation

1. **Installer PHP** si ce n'est pas déjà fait:
   - [Instructions d'installation PHP](/doc/installation.md#php-83)

2. **Télécharger les fichiers** dans votre répertoire de travail:
   - `transibase_converter.php`: Contient les classes et la logique de conversion
   - `transibase_dgeq_convert.php`: Script en ligne de commande utilisant ces classes

3. **Vérifier l'installation et la compatibilité**:
   ```bash
   php --version
   ```
   Assurez-vous que la version est 8.3 ou supérieure.

## Utilisation

### Exécution en ligne de commande

```bash
php transibase_dgeq_convert.php <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Exemple:
```bash
php transibase_dgeq_convert.php donnees.json rapport.csv 2023
```

### Rendre le script exécutable (Linux/macOS)

Pour une utilisation plus pratique sous Linux/macOS, vous pouvez rendre le script exécutable:

```bash
chmod +x transibase_dgeq_convert.php
```

Puis l'exécuter directement:
```bash
./transibase_dgeq_convert.php <fichier_entrée.json> <fichier_sortie.csv> [année]
```

Le shebang au début du fichier `#!/usr/bin/env php` permet cette exécution directe.

### Traitement par lots

Pour traiter plusieurs fichiers JSON en une seule commande:

```bash
for file in *.json; do
  output="${file%.json}.csv"
  php transibase_dgeq_convert.php "$file" "$output"
done
```

## Utilisation sur un serveur web

Le projet est structuré de manière à faciliter l'intégration dans un environnement web:

1. **Structure des fichiers**:
   - `transibase_converter.php`: Contient les classes et la logique de conversion
   - `transibase_dgeq_convert.php`: Script en ligne de commande qui utilise ces classes

2. **Intégration dans une application web**:
   - Incluez simplement le fichier `transibase_converter.php` dans votre application
   - Utilisez la classe `TransibaseConverter` pour traiter les données

3. **Exemple d'interface web**:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Convertisseur JSON vers CSV</title>
</head>
<body>
    <h1>Convertisseur JSON vers CSV pour DGEQ</h1>
    <form action="process.php" method="post" enctype="multipart/form-data">
        <p><input type="file" name="jsonFile" accept=".json"></p>
        <p>Filtrer par année: <input type="text" name="year" pattern="[0-9]{4}" placeholder="YYYY" title="Entrez une année à 4 chiffres"></p>
        <p><input type="submit" value="Convertir"></p>
    </form>
</body>
</html>
```

4. **Script de traitement** (`process.php`):

```php
<?php
// Inclure la classe de conversion
require_once 'transibase_converter.php';

// Vérifier si un fichier a été téléchargé
if (!isset($_FILES['jsonFile']) || $_FILES['jsonFile']['error'] !== UPLOAD_ERR_OK) {
    die("Erreur lors du téléchargement du fichier.");
}

// Récupérer l'année de filtrage (optionnelle)
$filterYear = !empty($_POST['year']) ? $_POST['year'] : null;

// Vérifier le format de l'année si spécifiée
if ($filterYear && !preg_match('/^\d{4}$/', $filterYear)) {
    die("L'année doit être au format YYYY (ex: 2023).");
}

try {
    // Lire le fichier JSON téléchargé
    $jsonContent = file_get_contents($_FILES['jsonFile']['tmp_name']);
    
    // Créer l'instance du convertisseur
    $converter = new TransibaseConverter($filterYear);
    
    // Traiter les données JSON
    $extractedData = $converter->processJsonString($jsonContent);
    
    if (empty($extractedData)) {
        die("Aucune transaction trouvée" . ($filterYear ? " pour l'année $filterYear." : "."));
    }
    
    // Générer le CSV
    $csvContent = $converter->generateCSV($extractedData);
    
    // Envoyer le fichier CSV au navigateur
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="export_dgeq.csv"');
    echo $csvContent;
    
} catch (Exception $e) {
    die("Erreur lors du traitement: " . $e->getMessage());
}
```

Cette structure modulaire permet d'intégrer facilement la fonctionnalité dans une application web PHP existante.

## Fonctionnalités spécifiques

### Avantages de la version PHP

- **Disponibilité**: PHP est installé sur la plupart des serveurs web
- **Intégration web**: Peut être intégré dans des applications web existantes
- **Structure orientée objet**: Plus facile à maintenir et étendre
- **Validation stricte des types**: Réduit les erreurs potentielles

### Fonctionnalités du script

- Typage strict avec PHP 8.3
- Classes pour les structures de données (Transaction, ExtractedData)
- Gestion des exceptions pour une robustesse accrue
- Formatage CSV respectant strictement le standard RFC 4180
- Support multilingue (caractères accentués)
- Méthodes spécifiques pour l'utilisation web (`processJsonString`, `generateCSV`)

## Dépannage

### Problèmes courants

- **"PHP version..."**: Le script nécessite PHP 8.3+. Vérifiez votre version avec `php --version`.

- **"fputcsv(): the $escape parameter must be provided"**: Cette alerte de dépréciation n'empêche pas le fonctionnement, mais indique que vous utilisez une version de PHP où le paramètre d'échappement devient obligatoire.

- **Caractères accentués mal affichés**: Assurez-vous que vos fichiers sont encodés en UTF-8 et que PHP est configuré pour utiliser UTF-8 par défaut.

### Solutions spécifiques

- **Mettre à jour PHP**:
  - Debian/Ubuntu: 
    ```bash
    sudo add-apt-repository ppa:ondrej/php
    sudo apt update
    sudo apt install php8.3
    ```
  - macOS: 
    ```bash
    brew update
    brew install php
    ```

- **Désactiver temporairement les avertissements**:
  ```bash
  php -d error_reporting=E_ERROR transibase_dgeq_convert.php ...
  ```

- **Problèmes de mémoire pour gros fichiers**:
  ```bash
  php -d memory_limit=512M transibase_dgeq_convert.php ...
  ```

- **Erreur lors de l'inclusion de `transibase_converter.php`**:
  Vérifiez que ce fichier se trouve bien dans le même répertoire que votre script. Si ce n'est pas le cas, ajustez le chemin:
  ```php
  require_once '/chemin/complet/vers/transibase_converter.php';
  ```

Pour plus d'informations sur le dépannage, consultez le [guide de dépannage général](/doc/troubleshooting.md).