#!/usr/bin/env php
<?php
declare(strict_types=1);
/**
 * Transibase 1.0 - Extracteur de données JSON vers CSV (Interface CLI)
 * 
 * Ce script permet d'extraire des données spécifiques depuis les commandes Craft Commerce
 * exportées en JSON et de les convertir en format CSV.
 * 
 * Ce script est disponible en plusieurs versions:
 * - JavaScript (Node.js): transibase_dgeq_convert.js
 * - TypeScript (Node.js): transibase_dgeq_convert_node.ts
 * - TypeScript (Deno): transibase_dgeq_convert_deno.ts
 * - TypeScript (Bun): transibase_dgeq_convert_bun.ts
 * - Python 3: transibase_dgeq_convert.py
 * - PHP 8.3+: transibase_dgeq_convert.php
 * - Go: transibase_dgeq_convert.go
 * 
 * @copyright 2025 Québec Studio
 * @license GNU General Public License v3.0 (GPL-3.0)
 * @author Québec Studio
 * @version 1.0.0
 * 
 * Ce script fait partie du logiciel Transibase 1.0 développé par Québec Studio.
 * 
 * Ce programme est un logiciel libre ; vous pouvez le redistribuer et/ou le modifier
 * selon les termes de la Licence Publique Générale GNU publiée par la Free Software
 * Foundation ; soit la version 3 de la licence, soit (à votre gré) toute version
 * ultérieure.
 * 
 * Ce programme est distribué dans l'espoir qu'il sera utile, mais SANS AUCUNE GARANTIE ;
 * sans même la garantie tacite de QUALITÉ MARCHANDE ou d'ADÉQUATION à UN BUT PARTICULIER.
 * Consultez la Licence Publique Générale GNU pour plus de détails.
 * 
 * Vous devriez avoir reçu une copie de la Licence Publique Générale GNU avec ce programme ;
 * si ce n'est pas le cas, consultez <https://www.gnu.org/licenses/licenses.fr.html>.
 */

// Inclure la classe de conversion
require_once __DIR__ . '/transibase_converter.php';

// Point d'entrée du script
function main(): void {
    global $argc, $argv;
    
    // Vérification des arguments de ligne de commande
    if ($argc < 3) {
        echo "Usage: php transibase_dgeq_convert.php <inputFile> <outputFile> [year]\n";
        echo "  inputFile: Chemin vers le fichier JSON d'entrée\n";
        echo "  outputFile: Chemin vers le fichier CSV de sortie\n";
        echo "  year: (Optionnel) Année pour filtrer les transactions (format: YYYY)\n";
        exit(1);
    }
    
    $inputFilePath = $argv[1];
    $outputFilePath = $argv[2];
    $filterYear = $argv[3] ?? null;
    
    // Vérifier que le fichier d'entrée existe
    if (!file_exists($inputFilePath)) {
        echo "Erreur: Le fichier d'entrée {$inputFilePath} n'existe pas.\n";
        exit(1);
    }
    
    // Vérifier le format de l'année si spécifiée
    if ($filterYear && !preg_match('/^\d{4}$/', $filterYear)) {
        echo "Erreur: L'année doit être au format YYYY (ex: 2023).\n";
        exit(1);
    }
    
    // Vérifier si le fichier de sortie existe déjà
    if (file_exists($outputFilePath)) {
        echo "Le fichier {$outputFilePath} existe déjà. Voulez-vous l'écraser ? (o/n) ";
        $handle = fopen("php://stdin", "r");
        $line = trim(fgets($handle));
        fclose($handle);
        
        if (strtolower($line) !== 'o') {
            echo "Opération annulée.\n";
            exit(0);
        }
    }
    
    try {
        $converter = new TransibaseConverter($filterYear);
        $converter->process($inputFilePath, $outputFilePath);
    } catch (Exception $e) {
        echo "Erreur lors du traitement: " . $e->getMessage() . "\n";
        exit(1);
    }
}

// Exécution du script
main();