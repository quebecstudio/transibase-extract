/**
 * Transibase 1.0 - Extracteur de données JSON vers CSV (Version Rust)
 * 
 * Ce script permet d'extraire des données spécifiques depuis les commandes Craft Commerce
 * exportées en JSON et de les convertir en format CSV.
 * 
 * @copyright 2025 Québec Studio
 * @license GNU General Public License v3.0 (GPL-3.0)
 * @author Québec Studio
 * @version 1.0.0
 */

 use std::env;
 use std::fs;
 use std::io::{self, Write};
 use std::path::Path;
 use std::process;
 use serde::{Deserialize, Serialize};
 use serde_json::Value;
 use csv::WriterBuilder;
 use regex::Regex;
 use chrono::NaiveDate;
 
 // Structure pour les transactions
 #[derive(Debug, Deserialize, Serialize)]
 struct Transaction {
     reference: Option<String>,
     dateCreated: Option<String>,
 }
 
 // Structure pour les clients
 #[derive(Debug, Deserialize, Serialize)]
 struct Customer {
     email: Option<String>,
 }
 
 // Structure pour les options des produits
 #[derive(Debug, Deserialize, Serialize)]
 struct Options {
     prenom: Option<String>,
     nom: Option<String>,
     dateNaissance: Option<String>,
     donationAmount: Option<String>,
 }
 
 // Structure pour les éléments de ligne
 #[derive(Debug, Deserialize, Serialize)]
 struct LineItem {
     options: Option<Options>,
 }
 
 // Structure pour les données de commande
 #[derive(Debug, Deserialize, Serialize)]
 struct OrderData {
     transactions: Option<Vec<Transaction>>,
     customer: Option<Customer>,
     lineItems: Option<Vec<LineItem>>,
 }
 
 // Structure pour les données extraites
 #[derive(Debug, Serialize)]
 struct ExtractedData {
     reference: String,
     email: String,
     prenom: String,
     nom: String,
     dateNaissance: String,
     donationAmount: String,
     transactionDate: String,
 }
 
 // Structure principale du convertisseur
 struct TransibaseConverter {
     filter_year: Option<String>,
 }
 
 impl TransibaseConverter {
     // Constructeur
     fn new(filter_year: Option<String>) -> Self {
         TransibaseConverter { filter_year }
     }
 
     // Fonction pour extraire les données du JSON
     fn extract_data(&self, json_data: &[OrderData]) -> Vec<ExtractedData> {
         let mut extracted_data = Vec::new();
 
         for item in json_data {
             // Obtenir la dernière transaction
             let last_transaction = match &item.transactions {
                 Some(transactions) if !transactions.is_empty() => {
                     &transactions[transactions.len() - 1]
                 }
                 _ => continue, // Skip si pas de transaction
             };
 
             // Convertir la date de transaction au format AAAA-MM-JJ
             let transaction_date = match &last_transaction.dateCreated {
                 Some(date_str) if !date_str.is_empty() => {
                     if date_str.contains('T') {
                         // Format ISO
                         date_str.split('T').next().unwrap_or("").to_string()
                     } else {
                         // Tenter une conversion de date
                         match NaiveDate::parse_from_str(date_str, "%Y-%m-%d") {
                             Ok(date) => date.format("%Y-%m-%d").to_string(),
                             Err(_) => date_str.to_string(),
                         }
                     }
                 }
                 _ => String::new(),
             };
 
             // Extraire les données du client et des options
             let email = item.customer.as_ref().and_then(|c| c.email.clone()).unwrap_or_default();
             
             let (prenom, nom, date_naissance, donation_amount) = match item.lineItems.as_ref() {
                 Some(line_items) if !line_items.is_empty() => {
                     match &line_items[0].options {
                         Some(options) => (
                             options.prenom.clone().unwrap_or_default(),
                             options.nom.clone().unwrap_or_default(),
                             options.dateNaissance.clone().unwrap_or_default(),
                             options.donationAmount.clone().unwrap_or_default(),
                         ),
                         None => (String::new(), String::new(), String::new(), String::new()),
                     }
                 }
                 _ => (String::new(), String::new(), String::new(), String::new()),
             };
 
             let extracted_item = ExtractedData {
                 reference: last_transaction.reference.clone().unwrap_or_default(),
                 email,
                 prenom,
                 nom,
                 dateNaissance: date_naissance,
                 donationAmount: donation_amount,
                 transactionDate: transaction_date.clone(),
             };
 
             // Filtrer par année si spécifiée
             if let Some(filter_year) = &self.filter_year {
                 if transaction_date.len() >= 4 && &transaction_date[0..4] == filter_year {
                     extracted_data.push(extracted_item);
                 }
             } else {
                 extracted_data.push(extracted_item);
             }
         }
 
         extracted_data
     }
 
     // Fonction pour convertir les données en CSV
     fn convert_to_csv(&self, data: &[ExtractedData], output_file: &str) -> io::Result<()> {
         let file = fs::File::create(output_file)?;
         let mut wtr = WriterBuilder::new()
             .quote_style(csv::QuoteStyle::Always)
             .from_writer(file);
 
         // Écrire toutes les données
         for record in data {
             wtr.serialize(record)?;
         }
 
         wtr.flush()?;
         Ok(())
     }
 
     // Processus principal d'extraction et de conversion
     fn process(&self, input_file_path: &str, output_file_path: &str) -> io::Result<()> {
         // Lire le fichier JSON
         let file_content = fs::read_to_string(input_file_path)?;
         
         // Traiter le contenu JSON
         let json_data: Result<Vec<OrderData>, _> = serde_json::from_str(&file_content);
         
         let json_data = match json_data {
             Ok(data) => data,
             Err(_) => {
                 // Tenter de parser un objet unique
                 match serde_json::from_str::<OrderData>(&file_content) {
                     Ok(single_data) => vec![single_data],
                     Err(_) => {
                         // Essayer de réparer en ajoutant des crochets
                         let repaired_content = format!("[{}]", file_content);
                         match serde_json::from_str(&repaired_content) {
                             Ok(data) => data,
                             Err(e) => {
                                 return Err(io::Error::new(
                                     io::ErrorKind::InvalidData,
                                     format!("Le fichier JSON est mal formé et ne peut pas être réparé automatiquement: {}", e),
                                 ));
                             }
                         }
                     }
                 }
             }
         };
 
         // Extraire les données
         let extracted_data = self.extract_data(&json_data);
         
         // Vérifier si des données ont été extraites
         if extracted_data.is_empty() {
             match &self.filter_year {
                 Some(year) => println!("Aucune transaction trouvée pour l'année {}.", year),
                 None => println!("Aucune transaction trouvée."),
             }
             return Ok(());
         }
         
         // Convertir en CSV et écrire dans le fichier
         self.convert_to_csv(&extracted_data, output_file_path)?;
         
         println!("Extraction réussie! Fichier CSV créé: {}", output_file_path);
         println!("Nombre d'entrées traitées: {}", extracted_data.len());
         
         if let Some(year) = &self.filter_year {
             println!("Filtre appliqué: Année {}", year);
         }
         
         Ok(())
     }
 }
 
 // Fonction pour demander à l'utilisateur s'il veut écraser un fichier existant
 fn ask_for_overwrite(file_path: &str) -> bool {
     print!("Le fichier {} existe déjà. Voulez-vous l'écraser ? (o/n) ", file_path);
     io::stdout().flush().unwrap();
     
     let mut response = String::new();
     io::stdin().read_line(&mut response).unwrap();
     
     response.trim().to_lowercase() == "o"
 }
 
 fn main() {
     // Récupérer les arguments de la ligne de commande
     let args: Vec<String> = env::args().collect();
     
     if args.len() < 3 {
         println!("Usage: {} <inputFile> <outputFile> [year]", args[0]);
         println!("  inputFile: Chemin vers le fichier JSON d'entrée");
         println!("  outputFile: Chemin vers le fichier CSV de sortie");
         println!("  year: (Optionnel) Année pour filtrer les transactions (format: YYYY)");
         process::exit(1);
     }
     
     let input_file_path = &args[1];
     let output_file_path = &args[2];
     let filter_year = if args.len() > 3 { Some(args[3].clone()) } else { None };
     
     // Vérifier que le fichier d'entrée existe
     if !Path::new(input_file_path).exists() {
         println!("Erreur: Le fichier d'entrée {} n'existe pas.", input_file_path);
         process::exit(1);
     }
     
     // Vérifier le format de l'année si spécifiée
     if let Some(year) = &filter_year {
         if !Regex::new(r"^\d{4}$").unwrap().is_match(year) {
             println!("Erreur: L'année doit être au format YYYY (ex: 2023).");
             process::exit(1);
         }
     }
     
     // Vérifier si le fichier de sortie existe déjà
     if Path::new(output_file_path).exists() {
         if !ask_for_overwrite(output_file_path) {
             println!("Opération annulée.");
             process::exit(0);
         }
     }
     
     // Créer une instance du convertisseur
     let converter = TransibaseConverter::new(filter_year);
     
     // Traiter les données
     match converter.process(input_file_path, output_file_path) {
         Ok(_) => {},
         Err(e) => {
             println!("Erreur lors du traitement: {}", e);
             process::exit(1);
         }
     }
 }