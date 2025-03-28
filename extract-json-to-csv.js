/**
 * Transibase 1.0 - Extracteur de données JSON vers CSV
 * 
 * Ce script permet d'extraire des données spécifiques depuis les commandes Craft Commerce
 * exportées en JSON et de les convertir en format CSV.
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

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Création d'une interface pour les interactions avec l'utilisateur
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Fonction pour poser une question et obtenir une réponse
function question(query) {
  return new Promise(resolve => {
    rl.question(query, answer => {
      resolve(answer);
    });
  });
}

// Fonction pour extraire les données demandées
function extractData(jsonData, filterYear = null) {
  // S'assurer que jsonData est un tableau
  const dataArray = Array.isArray(jsonData) ? jsonData : [jsonData];
  
  return dataArray.map(item => {
    // Obtenir la dernière transaction
    const lastTransaction = item.transactions && item.transactions.length > 0 
      ? item.transactions[item.transactions.length - 1] 
      : { reference: '', dateCreated: '' };

    // Convertir la date de la transaction au format AAAA-MM-JJ
    let transactionDate = '';
    if (lastTransaction.dateCreated) {
      // Si la date est au format ISO
      if (lastTransaction.dateCreated.includes('T')) {
        transactionDate = lastTransaction.dateCreated.split('T')[0];
      } 
      // Si la date est dans un autre format, tentative de conversion
      else {
        try {
          const date = new Date(lastTransaction.dateCreated);
          transactionDate = date.toISOString().split('T')[0];
        } catch (e) {
          transactionDate = lastTransaction.dateCreated;
        }
      }
    }
    
    // Extraire les informations demandées
    return {
      reference: lastTransaction.reference || '',
      email: item.customer?.email || '',
      prenom: item.lineItems && item.lineItems[0]?.options?.prenom || '',
      nom: item.lineItems && item.lineItems[0]?.options?.nom || '',
      dateNaissance: item.lineItems && item.lineItems[0]?.options?.dateNaissance || '',
      donationAmount: item.lineItems && item.lineItems[0]?.options?.donationAmount || '',
      transactionDate: transactionDate
    };
  }).filter(item => {
    // Filtrer par année si spécifiée
    if (filterYear) {
      const year = item.transactionDate.split('-')[0];
      return year === filterYear;
    }
    return true;
  });
}

// Fonction pour convertir les données en format CSV
function convertToCSV(data) {
  // En-têtes CSV
  const header = ['reference', 'email', 'prenom', 'nom', 'dateNaissance', 'donationAmount', 'transactionDate'];
  
  // Lignes de données
  const rows = data.map(item => {
    return header.map(key => {
      // Échapper les guillemets et entourer les valeurs de guillemets
      const value = item[key]?.toString().replace(/"/g, '""') || '';
      return `"${value}"`;
    }).join(',');
  });
  
  // Joindre l'en-tête et les lignes
  return [header.join(','), ...rows].join('\n');
}

// Fonction principale
async function processJsonToCSV(inputFilePath, outputFilePath, filterYear = null) {
  try {
    // Vérifier si le fichier de sortie existe déjà
    if (fs.existsSync(outputFilePath)) {
      const answer = await question(`Le fichier ${outputFilePath} existe déjà. Voulez-vous l'écraser ? (o/n) `);
      if (answer.toLowerCase() !== 'o') {
        console.log('Opération annulée.');
        rl.close();
        return;
      }
    }

    // Lire le fichier JSON
    const fileContent = fs.readFileSync(inputFilePath, 'utf8');
    
    // Traiter le contenu JSON
    let jsonData;
    try {
      jsonData = JSON.parse(fileContent);
    } catch (e) {
      // Si le JSON est mal formé, essayer de le réparer
      // On suppose que le fichier pourrait être un tableau sans les crochets externes
      try {
        jsonData = JSON.parse(`[${fileContent}]`);
      } catch (e2) {
        throw new Error('Le fichier JSON est mal formé et ne peut pas être réparé automatiquement.');
      }
    }
    
    // Extraire les données avec filtre d'année si spécifié
    const extractedData = extractData(jsonData, filterYear);
    
    // Vérifier si des données ont été extraites
    if (extractedData.length === 0) {
      console.log(filterYear 
        ? `Aucune transaction trouvée pour l'année ${filterYear}.` 
        : 'Aucune transaction trouvée.');
      rl.close();
      return;
    }
    
    // Convertir en CSV
    const csvContent = convertToCSV(extractedData);
    
    // Écrire le fichier CSV
    fs.writeFileSync(outputFilePath, csvContent, 'utf8');
    
    console.log(`Extraction réussie! Fichier CSV créé: ${outputFilePath}`);
    console.log(`Nombre d'entrées traitées: ${extractedData.length}`);
    
    if (filterYear) {
      console.log(`Filtre appliqué: Année ${filterYear}`);
    }
    
  } catch (error) {
    console.error('Erreur lors du traitement:', error.message);
  } finally {
    rl.close();
  }
}

// Fonction principale avec gestion des arguments
async function main() {
  // Traitement des arguments de la ligne de commande
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log('Usage: node extract-json-to-csv.js <inputFile> <outputFile> [year]');
    console.log('  inputFile: Chemin vers le fichier JSON d\'entrée');
    console.log('  outputFile: Chemin vers le fichier CSV de sortie');
    console.log('  year: (Optionnel) Année pour filtrer les transactions (format: YYYY)');
    process.exit(1);
  }
  
  const inputFilePath = args[0];
  const outputFilePath = args[1];
  const filterYear = args[2] || null;
  
  // Vérifier que le fichier d'entrée existe
  if (!fs.existsSync(inputFilePath)) {
    console.error(`Erreur: Le fichier d'entrée ${inputFilePath} n'existe pas.`);
    process.exit(1);
  }
  
  // Vérifier le format de l'année si spécifiée
  if (filterYear && !/^\d{4}$/.test(filterYear)) {
    console.error('Erreur: L\'année doit être au format YYYY (ex: 2023).');
    process.exit(1);
  }
  
  await processJsonToCSV(inputFilePath, outputFilePath, filterYear);
}

// Exécuter le script
main();