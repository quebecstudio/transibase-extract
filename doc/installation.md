# Guide d'installation

Ce document fournit des instructions détaillées pour installer les différents environnements d'exécution nécessaires aux scripts Transibase.

## Table des matières
- [Node.js](#nodejs)
- [Deno](#deno)
- [Bun](#bun)
- [PHP 8.3+](#php-83)
- [Python 3](#python-3)

## Node.js

Node.js est nécessaire pour exécuter les versions JavaScript et TypeScript du script.

### Sur Windows

1. **Télécharger l'installateur**
   - Allez sur le site officiel de Node.js : https://nodejs.org/fr/
   - Téléchargez la version LTS (Long Term Support) recommandée pour la plupart des utilisateurs
   
2. **Installer Node.js**
   - Exécutez le fichier .msi téléchargé
   - Suivez les instructions de l'assistant d'installation
   - Laissez cocher l'option "Ajouter à la variable PATH" pendant l'installation
   
3. **Vérifier l'installation**
   - Ouvrez l'invite de commande (cmd) ou PowerShell
   - Tapez les commandes suivantes pour vérifier que Node.js et npm sont installés correctement:
   ```
   node --version
   npm --version
   ```

4. **Pour la version TypeScript (optionnel)**
   - Installez TypeScript et ts-node globalement:
   ```
   npm install -g typescript ts-node
   ```

### Sur macOS

1. **Méthode avec l'installateur**
   - Allez sur le site officiel de Node.js : https://nodejs.org/fr/
   - Téléchargez la version LTS pour macOS (.pkg)
   - Exécutez le fichier .pkg téléchargé et suivez les instructions
   
2. **Méthode avec Homebrew** (recommandée si vous utilisez déjà Homebrew)
   - Si vous n'avez pas encore Homebrew, installez-le en exécutant dans le Terminal:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   - Installez Node.js avec Homebrew:
   ```
   brew install node
   ```
   
3. **Vérifier l'installation**
   - Ouvrez le Terminal
   - Tapez les commandes suivantes:
   ```
   node --version
   npm --version
   ```

### Sur Linux (Debian/Ubuntu)

```bash
# Utiliser NodeSource pour obtenir une version à jour
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Vérifier l'installation
node --version
npm --version

# Pour TypeScript
sudo npm install -g typescript ts-node
```

## Deno

Deno est un runtime JavaScript/TypeScript moderne avec des fonctionnalités de sécurité intégrées.

### Sur Windows

1. **Installation avec PowerShell**
   ```powershell
   iwr https://deno.land/x/install/install.ps1 -useb | iex
   ```

2. **Vérifier l'installation**
   ```
   deno --version
   ```

### Sur macOS ou Linux

1. **Installation avec Shell**
   ```bash
   curl -fsSL https://deno.land/x/install/install.sh | sh
   ```
   
2. **Ajouter Deno au PATH** (si pas fait automatiquement)
   - Pour Bash (ajoutez dans `~/.bashrc` ou `~/.bash_profile`):
   ```bash
   export DENO_INSTALL="$HOME/.deno"
   export PATH="$DENO_INSTALL/bin:$PATH"
   ```
   
   - Pour Zsh (ajoutez dans `~/.zshrc`):
   ```bash
   export DENO_INSTALL="$HOME/.deno"
   export PATH="$DENO_INSTALL/bin:$PATH"
   ```
   
3. **Vérifier l'installation**
   ```bash
   deno --version
   ```

## Bun

Bun est un runtime JavaScript moderne, rapide et tout-en-un, incluant bundler, test runner et gestionnaire de packages.

### Sur macOS, Linux et WSL

```bash
# Installation
curl -fsSL https://bun.sh/install | bash

# Sourcer le shell pour utiliser immédiatement
source ~/.bashrc  # ou ~/.zshrc pour zsh

# Vérifier l'installation
bun --version
```

### Sur Windows

Bun est principalement utilisé sur Windows via WSL (Windows Subsystem for Linux).

1. **Installer WSL2**
   - Ouvrez PowerShell en tant qu'administrateur
   - Exécutez:
   ```powershell
   wsl --install
   ```
   - Redémarrez votre ordinateur
   
2. **Installer Bun dans WSL**
   - Ouvrez une fenêtre WSL (Ubuntu par défaut)
   - Suivez les instructions pour Linux ci-dessus

## PHP 8.3+

PHP 8.3 ou supérieur est requis pour la version PHP du script.

### Sur Windows

1. **Télécharger l'installateur**
   - Allez sur le site officiel de PHP: https://windows.php.net/download/
   - Téléchargez la version PHP 8.3 ou supérieure (version Thread Safe recommandée)

2. **Installer PHP**
   - Décompressez le fichier téléchargé dans un dossier (par exemple, `C:\php`)
   - Ajoutez ce dossier à votre variable d'environnement PATH:
     - Cliquez droit sur Démarrer > Système > Paramètres système avancés
     - Cliquez sur "Variables d'environnement"
     - Sous "Variables système", trouvez PATH et cliquez sur "Modifier"
     - Cliquez sur "Nouveau" et ajoutez `C:\php` (ou le chemin où vous avez décompressé PHP)
     - Cliquez sur OK pour fermer toutes les fenêtres
   - Copiez `php.ini-development` en `php.ini`

3. **Configurer php.ini**
   - Ouvrez `php.ini` dans un éditeur de texte
   - Décommentez les extensions suivantes en retirant le `;` au début des lignes:
     ```
     extension=json
     extension=fileinfo
     ```

4. **Vérifier l'installation**
   - Ouvrez un nouveau terminal (cmd ou PowerShell)
   ```
   php --version
   ```

### Sur macOS

1. **Avec Homebrew**
   ```bash
   # Installer PHP 8.3
   brew install php@8.3
   
   # Définir comme version par défaut
   brew link php@8.3 --force
   
   # Vérifier l'installation
   php --version
   ```

### Sur Linux (Debian/Ubuntu)

```bash
# Ajouter le dépôt PPA Ondřej Surý (maintient les versions PHP récentes)
sudo add-apt-repository ppa:ondrej/php
sudo apt update

# Installer PHP 8.3 et les extensions nécessaires
sudo apt install php8.3 php8.3-cli php8.3-common php8.3-json

# Vérifier l'installation
php --version
```

## Python 3

Python 3.6 ou supérieur est requis pour la version Python du script.

### Sur Windows

1. **Télécharger l'installateur**
   - Allez sur le site officiel de Python : https://www.python.org/downloads/
   - Téléchargez la dernière version de Python 3.x
   
2. **Installer Python**
   - Exécutez le fichier .exe téléchargé
   - **Important**: Cochez la case "Add Python to PATH" avant de cliquer sur "Install Now"
   
3. **Vérifier l'installation**
   - Ouvrez l'invite de commande (cmd) ou PowerShell
   - Tapez la commande suivante:
   ```
   python --version
   ```
   - Si cela ne fonctionne pas, essayez:
   ```
   py --version
   ```

### Sur macOS

La plupart des systèmes macOS ont déjà Python installé. Pour vérifier et installer si nécessaire:

1. **Vérifier l'installation**
   - Ouvrez le Terminal
   - Tapez:
   ```
   python3 --version
   ```

2. **Si Python n'est pas installé**:
   - Utilisez Homebrew:
   ```
   brew install python
   ```
   - Ou téléchargez l'installateur depuis https://www.python.org/downloads/macos/

### Sur Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install python3 python3-pip

# Vérifier l'installation
python3 --version
```

## Vérification finale

Après l'installation, vérifiez que les runtimes nécessaires sont bien installés:

```bash
# Vérifier Node.js
node --version

# Vérifier TypeScript (si installé)
tsc --version
ts-node --version

# Vérifier Deno
deno --version

# Vérifier Bun
bun --version

# Vérifier PHP
php --version

# Vérifier Python
python3 --version  # ou python --version sur Windows
```