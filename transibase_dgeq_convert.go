package main

/**
 * Transibase 1.0 - Extracteur de données JSON vers CSV (Version Go)
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

import (
	"bufio"
	"encoding/csv"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
	"time"
)

// Définition des structures pour le JSON
type Options struct {
	Prenom         string `json:"prenom"`
	Nom            string `json:"nom"`
	DateNaissance  string `json:"dateNaissance"`
	DonationAmount string `json:"donationAmount"`
}

type LineItem struct {
	Options Options `json:"options"`
}

type Transaction struct {
	Reference   string `json:"reference"`
	DateCreated string `json:"dateCreated"`
}

type Customer struct {
	Email string `json:"email"`
}

type OrderData struct {
	Transactions []Transaction `json:"transactions"`
	Customer     Customer      `json:"customer"`
	LineItems    []LineItem    `json:"lineItems"`
}

// Structure pour les données extraites
type ExtractedData struct {
	Reference       string
	Email           string
	Prenom          string
	Nom             string
	DateNaissance   string
	DonationAmount  string
	TransactionDate string
}

// TransibaseConverter structure avec fonction de filtrage par année
type TransibaseConverter struct {
	FilterYear string
}

// Nouvelle instance de TransibaseConverter
func NewTransibaseConverter(filterYear string) *TransibaseConverter {
	return &TransibaseConverter{
		FilterYear: filterYear,
	}
}

// Extrait les données des commandes
func (tc *TransibaseConverter) ExtractData(jsonData []OrderData) []ExtractedData {
	var extractedData []ExtractedData

	for _, item := range jsonData {
		// Obtenir la dernière transaction
		var lastTransaction Transaction
		if len(item.Transactions) > 0 {
			lastTransaction = item.Transactions[len(item.Transactions)-1]
		}

		// Convertir la date de la transaction au format AAAA-MM-JJ
		transactionDate := ""
		if lastTransaction.DateCreated != "" {
			dateStr := lastTransaction.DateCreated
			// Si la date est au format ISO
			if strings.Contains(dateStr, "T") {
				transactionDate = strings.Split(dateStr, "T")[0]
			} else {
				// Si la date est dans un autre format, tentative de conversion
				t, err := time.Parse(time.RFC3339, dateStr)
				if err != nil {
					// Essayer d'autres formats
					t, err = time.Parse("2006-01-02", dateStr)
					if err != nil {
						// Si la conversion échoue, garder la chaîne originale
						transactionDate = dateStr
					} else {
						transactionDate = t.Format("2006-01-02")
					}
				} else {
					transactionDate = t.Format("2006-01-02")
				}
			}
		}

		// Extraire les informations de base
		email := item.Customer.Email

		// Extraire les données des options
		prenom := ""
		nom := ""
		dateNaissance := ""
		donationAmount := ""

		if len(item.LineItems) > 0 {
			options := item.LineItems[0].Options
			prenom = options.Prenom
			nom = options.Nom
			dateNaissance = options.DateNaissance
			donationAmount = options.DonationAmount
		}

		extractedItem := ExtractedData{
			Reference:       lastTransaction.Reference,
			Email:           email,
			Prenom:          prenom,
			Nom:             nom,
			DateNaissance:   dateNaissance,
			DonationAmount:  donationAmount,
			TransactionDate: transactionDate,
		}

		// Filtrer par année si spécifiée
		if tc.FilterYear != "" {
			if len(transactionDate) >= 4 {
				year := transactionDate[0:4]
				if year == tc.FilterYear {
					extractedData = append(extractedData, extractedItem)
				}
			}
		} else {
			extractedData = append(extractedData, extractedItem)
		}
	}

	return extractedData
}

// Convertit les données en format CSV et les écrit dans un fichier
func (tc *TransibaseConverter) ConvertToCSV(data []ExtractedData, outputFile string) error {
	file, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	defer file.Close()

	// Créer un writer CSV qui respecte le standard RFC 4180
	writer := csv.NewWriter(file)
	writer.Comma = ','
	defer writer.Flush()

	// Tous les champs doivent être entourés de guillemets
	// Cette configuration n'est pas directement possible avec la bibliothèque standard csv
	// mais nous allons nous assurer que les données sont correctement échappées

	// En-têtes CSV
	header := []string{"reference", "email", "prenom", "nom", "dateNaissance", "donationAmount", "transactionDate"}
	if err := writer.Write(header); err != nil {
		return err
	}

	// Lignes de données
	for _, item := range data {
		record := []string{
			item.Reference,
			item.Email,
			item.Prenom,
			item.Nom,
			item.DateNaissance,
			item.DonationAmount,
			item.TransactionDate,
		}
		if err := writer.Write(record); err != nil {
			return err
		}
	}

	return nil
}

// Processus principal d'extraction et de conversion
func (tc *TransibaseConverter) Process(inputFilePath, outputFilePath string) error {
	// Lire le fichier JSON
	fileContent, err := ioutil.ReadFile(inputFilePath)
	if err != nil {
		return err
	}

	// Traiter le contenu JSON
	var jsonData []OrderData
	err = json.Unmarshal(fileContent, &jsonData)
	if err != nil {
		// Si le JSON est mal formé, essayer de le réparer
		var singleData OrderData
		err = json.Unmarshal(fileContent, &singleData)
		if err != nil {
			// Essayer de réparer en ajoutant des crochets
			fixedContent := "[" + string(fileContent) + "]"
			err = json.Unmarshal([]byte(fixedContent), &jsonData)
			if err != nil {
				return errors.New("Le fichier JSON est mal formé et ne peut pas être réparé automatiquement")
			}
		} else {
			jsonData = []OrderData{singleData}
		}
	}

	// Extraire les données
	extractedData := tc.ExtractData(jsonData)

	// Vérifier si des données ont été extraites
	if len(extractedData) == 0 {
		if tc.FilterYear != "" {
			fmt.Printf("Aucune transaction trouvée pour l'année %s.\n", tc.FilterYear)
		} else {
			fmt.Println("Aucune transaction trouvée.")
		}
		return nil
	}

	// Convertir en CSV et écrire dans le fichier
	err = tc.ConvertToCSV(extractedData, outputFilePath)
	if err != nil {
		return err
	}

	fmt.Printf("Extraction réussie! Fichier CSV créé: %s\n", outputFilePath)
	fmt.Printf("Nombre d'entrées traitées: %d\n", len(extractedData))

	if tc.FilterYear != "" {
		fmt.Printf("Filtre appliqué: Année %s\n", tc.FilterYear)
	}

	return nil
}

// Fonction pour demander à l'utilisateur s'il veut écraser un fichier existant
func askForOverwrite(filePath string) bool {
	reader := bufio.NewReader(os.Stdin)
	fmt.Printf("Le fichier %s existe déjà. Voulez-vous l'écraser ? (o/n) ", filePath)
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(strings.ToLower(response))
	return response == "o"
}

func main() {
	// Vérifier les arguments
	if len(os.Args) < 3 {
		fmt.Println("Usage: go run transibase_dgeq_convert.go <inputFile> <outputFile> [year]")
		fmt.Println("  inputFile: Chemin vers le fichier JSON d'entrée")
		fmt.Println("  outputFile: Chemin vers le fichier CSV de sortie")
		fmt.Println("  year: (Optionnel) Année pour filtrer les transactions (format: YYYY)")
		os.Exit(1)
	}

	inputFilePath := os.Args[1]
	outputFilePath := os.Args[2]
	var filterYear string
	if len(os.Args) > 3 {
		filterYear = os.Args[3]
	}

	// Vérifier que le fichier d'entrée existe
	if _, err := os.Stat(inputFilePath); os.IsNotExist(err) {
		fmt.Printf("Erreur: Le fichier d'entrée %s n'existe pas.\n", inputFilePath)
		os.Exit(1)
	}

	// Vérifier le format de l'année si spécifiée
	if filterYear != "" {
		matched, _ := regexp.MatchString(`^\d{4}$`, filterYear)
		if !matched {
			fmt.Println("Erreur: L'année doit être au format YYYY (ex: 2023).")
			os.Exit(1)
		}
	}

	// Vérifier si le fichier de sortie existe déjà
	if _, err := os.Stat(outputFilePath); err == nil {
		if !askForOverwrite(outputFilePath) {
			fmt.Println("Opération annulée.")
			os.Exit(0)
		}
	}

	// Créer une instance du convertisseur
	converter := NewTransibaseConverter(filterYear)

	// Traiter les données
	err := converter.Process(inputFilePath, outputFilePath)
	if err != nil {
		fmt.Printf("Erreur lors du traitement: %s\n", err)
		os.Exit(1)
	}
}