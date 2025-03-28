<?php
declare(strict_types=1);
/**
 * Transibase 1.0 - Extracteur de données JSON vers CSV (Classes principales)
 * 
 * Ce fichier contient les classes principales pour l'extraction de données 
 * depuis un JSON de commandes Craft Commerce et leur conversion en CSV.
 * 
 * @copyright 2025 Québec Studio
 * @license GNU General Public License v3.0 (GPL-3.0)
 * @author Québec Studio
 * @version 1.0.0
 */

// Définir les types pour les données
class Transaction {
    public string $reference;
    public string $dateCreated;
    
    public function __construct(string $reference = '', string $dateCreated = '') {
        $this->reference = $reference;
        $this->dateCreated = $dateCreated;
    }
}

class ExtractedData {
    public string $reference;
    public string $email;
    public string $prenom;
    public string $nom;
    public string $dateNaissance;
    public string $donationAmount;
    public string $transactionDate;
    
    public function __construct(
        string $reference = '',
        string $email = '',
        string $prenom = '',
        string $nom = '',
        string $dateNaissance = '',
        string $donationAmount = '',
        string $transactionDate = ''
    ) {
        $this->reference = $reference;
        $this->email = $email;
        $this->prenom = $prenom;
        $this->nom = $nom;
        $this->dateNaissance = $dateNaissance;
        $this->donationAmount = $donationAmount;
        $this->transactionDate = $transactionDate;
    }
    
    // Convertir l'objet en tableau
    public function toArray(): array {
        return [
            'reference' => $this->reference,
            'email' => $this->email,
            'prenom' => $this->prenom,
            'nom' => $this->nom,
            'dateNaissance' => $this->dateNaissance,
            'donationAmount' => $this->donationAmount,
            'transactionDate' => $this->transactionDate
        ];
    }
}

/**
 * Classe principale pour le traitement des données
 */
class TransibaseConverter {
    private ?string $filterYear;
    
    public function __construct(?string $filterYear = null) {
        $this->filterYear = $filterYear;
    }
    
    /**
     * Extrait les données demandées du JSON
     *
     * @param array $jsonData Les données JSON à traiter
     * @return array<ExtractedData> Liste des données extraites
     */
    public function extractData(array $jsonData): array {
        // S'assurer que jsonData est un tableau
        $dataArray = array_key_exists(0, $jsonData) ? $jsonData : [$jsonData];
        
        $extractedData = [];
        
        foreach ($dataArray as $item) {
            // Obtenir la dernière transaction
            $lastTransaction = new Transaction();
            
            if (isset($item['transactions']) && is_array($item['transactions']) && !empty($item['transactions'])) {
                $lastTx = end($item['transactions']);
                $lastTransaction = new Transaction(
                    $lastTx['reference'] ?? '',
                    $lastTx['dateCreated'] ?? ''
                );
            }
            
            // Convertir la date de la transaction au format AAAA-MM-JJ
            $transactionDate = '';
            
            if ($lastTransaction->dateCreated) {
                $dateStr = $lastTransaction->dateCreated;
                
                // Si la date est au format ISO
                if (str_contains($dateStr, 'T')) {
                    $transactionDate = explode('T', $dateStr)[0];
                } else {
                    // Si la date est dans un autre format, tentative de conversion
                    try {
                        $date = new DateTime($dateStr);
                        $transactionDate = $date->format('Y-m-d');
                    } catch (Exception) {
                        $transactionDate = $dateStr;
                    }
                }
            }
            
            // Extraire les informations de base
            $email = $item['customer']['email'] ?? '';
            
            // Extraire les données des options
            $prenom = '';
            $nom = '';
            $dateNaissance = '';
            $donationAmount = '';
            
            if (isset($item['lineItems'][0]['options'])) {
                $options = $item['lineItems'][0]['options'];
                $prenom = $options['prenom'] ?? '';
                $nom = $options['nom'] ?? '';
                $dateNaissance = $options['dateNaissance'] ?? '';
                $donationAmount = $options['donationAmount'] ?? '';
            }
            
            $extractedItem = new ExtractedData(
                $lastTransaction->reference,
                $email,
                $prenom,
                $nom,
                $dateNaissance,
                $donationAmount,
                $transactionDate
            );
            
            // Filtrer par année si spécifiée
            if ($this->filterYear) {
                $year = explode('-', $transactionDate)[0] ?? '';
                
                if ($year === $this->filterYear) {
                    $extractedData[] = $extractedItem;
                }
            } else {
                $extractedData[] = $extractedItem;
            }
        }
        
        return $extractedData;
    }
    
    /**
     * Convertit les données en format CSV et les écrit dans un fichier
     * Tous les champs sont entourés de guillemets doubles comme dans les autres versions
     *
     * @param array<ExtractedData> $data Les données à convertir
     * @param string $outputFile Le fichier de sortie
     * @return void
     * @throws RuntimeException Si le fichier ne peut pas être ouvert
     */
    public function convertToCSV(array $data, string $outputFile): void {
        // En-têtes CSV
        $header = ['reference', 'email', 'prenom', 'nom', 'dateNaissance', 'donationAmount', 'transactionDate'];
        
        // Ouvrir le fichier en écriture
        $fp = fopen($outputFile, 'w');
        
        if ($fp === false) {
            throw new RuntimeException("Impossible d'ouvrir le fichier de sortie en écriture.");
        }
        
        // Méthode manuelle avec formatage personnalisé pour assurer que TOUS les champs
        // sont encadrés par des guillemets doubles et que ces guillemets sont échappés
        
        // Écrire l'en-tête avec guillemets pour tous les champs
        $headerLine = implode(',', array_map(fn($field) => '"' . $field . '"', $header));
        fwrite($fp, $headerLine . "\n");
        
        // Écrire les lignes de données
        foreach ($data as $item) {
            $rowData = $item->toArray();
            $line = [];
            
            foreach ($header as $field) {
                $value = $rowData[$field] ?? '';
                // Échapper les guillemets doubles par des guillemets doubles (standard CSV)
                $value = str_replace('"', '""', $value);
                $line[] = '"' . $value . '"';
            }
            
            fwrite($fp, implode(',', $line) . "\n");
        }
        
        fclose($fp);
    }
    
    /**
     * Génère un contenu CSV sans l'écrire dans un fichier (utile pour le contexte web)
     *
     * @param array<ExtractedData> $data Les données à convertir
     * @return string Le contenu CSV
     */
    public function generateCSV(array $data): string {
        // En-têtes CSV
        $header = ['reference', 'email', 'prenom', 'nom', 'dateNaissance', 'donationAmount', 'transactionDate'];
        
        // Méthode manuelle avec formatage personnalisé pour assurer que TOUS les champs
        // sont encadrés par des guillemets doubles et que ces guillemets sont échappés
        
        // Préparer l'en-tête avec guillemets pour tous les champs
        $lines = [implode(',', array_map(fn($field) => '"' . $field . '"', $header))];
        
        // Préparer les lignes de données
        foreach ($data as $item) {
            $rowData = $item->toArray();
            $line = [];
            
            foreach ($header as $field) {
                $value = $rowData[$field] ?? '';
                // Échapper les guillemets doubles par des guillemets doubles (standard CSV)
                $value = str_replace('"', '""', $value);
                $line[] = '"' . $value . '"';
            }
            
            $lines[] = implode(',', $line);
        }
        
        return implode("\n", $lines);
    }
    
    /**
     * Processus principal d'extraction et de conversion
     *
     * @param string $inputFilePath Chemin vers le fichier JSON d'entrée
     * @param string $outputFilePath Chemin vers le fichier CSV de sortie
     * @return void
     * @throws Exception Si une erreur survient lors du traitement
     */
    public function process(string $inputFilePath, string $outputFilePath): void {
        // Lire le fichier JSON
        $fileContent = file_get_contents($inputFilePath);
        
        if ($fileContent === false) {
            throw new RuntimeException("Impossible de lire le fichier d'entrée.");
        }
        
        // Traiter le contenu JSON
        try {
            $jsonData = json_decode($fileContent, true, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            // Si le JSON est mal formé, essayer de le réparer
            try {
                $jsonData = json_decode('[' . $fileContent . ']', true, 512, JSON_THROW_ON_ERROR);
            } catch (JsonException) {
                throw new RuntimeException("Le fichier JSON est mal formé et ne peut pas être réparé automatiquement.");
            }
        }
        
        // Extraire les données
        $extractedData = $this->extractData($jsonData);
        
        // Vérifier si des données ont été extraites
        if (empty($extractedData)) {
            if ($this->filterYear) {
                echo "Aucune transaction trouvée pour l'année {$this->filterYear}.\n";
            } else {
                echo "Aucune transaction trouvée.\n";
            }
            return;
        }
        
        // Convertir en CSV et écrire dans le fichier
        $this->convertToCSV($extractedData, $outputFilePath);
        
        echo "Extraction réussie! Fichier CSV créé: {$outputFilePath}\n";
        echo "Nombre d'entrées traitées: " . count($extractedData) . "\n";
        
        if ($this->filterYear) {
            echo "Filtre appliqué: Année {$this->filterYear}\n";
        }
    }
    
    /**
     * Processus d'extraction à partir d'une chaîne JSON
     * Utile pour traiter les données JSON dans un contexte web
     * 
     * @param string $jsonContent Le contenu JSON
     * @return array<ExtractedData> Les données extraites
     * @throws RuntimeException Si le JSON est mal formé
     */
    public function processJsonString(string $jsonContent): array {
        // Traiter le contenu JSON
        try {
            $jsonData = json_decode($jsonContent, true, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            // Si le JSON est mal formé, essayer de le réparer
            try {
                $jsonData = json_decode('[' . $jsonContent . ']', true, 512, JSON_THROW_ON_ERROR);
            } catch (JsonException) {
                throw new RuntimeException("Le fichier JSON est mal formé et ne peut pas être réparé automatiquement.");
            }
        }
        
        // Extraire les données
        return $this->extractData($jsonData);
    }
}