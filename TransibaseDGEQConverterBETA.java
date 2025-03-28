/**
 * Transibase 1.0 - Extracteur de données JSON vers CSV (Version Java)
 * 
 * Ce script permet d'extraire des données spécifiques depuis les commandes Craft Commerce
 * exportées en JSON et de les convertir en format CSV.
 * 
 * @copyright 2025 Québec Studio
 * @license GNU General Public License v3.0 (GPL-3.0)
 * @author Québec Studio
 * @version 1.0.0
 */

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.regex.Pattern;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;

public class TransibaseDGEQConverter {

    // Classe pour les données extraites
    private static class ExtractedData {
        private String reference;
        private String email;
        private String prenom;
        private String nom;
        private String dateNaissance;
        private String donationAmount;
        private String transactionDate;

        public ExtractedData() {
            this.reference = "";
            this.email = "";
            this.prenom = "";
            this.nom = "";
            this.dateNaissance = "";
            this.donationAmount = "";
            this.transactionDate = "";
        }

        public String[] toArray() {
            return new String[] {
                reference, email, prenom, nom, dateNaissance, donationAmount, transactionDate
            };
        }
    }

    // Classe principale du convertisseur
    private static class TransibaseConverter {
        private String filterYear;

        public TransibaseConverter(String filterYear) {
            this.filterYear = filterYear;
        }

        /**
         * Extrait les données demandées du JSON
         *
         * @param jsonArray Les données JSON à traiter
         * @return Liste des données extraites
         */
        public List<ExtractedData> extractData(JsonArray jsonArray) {
            List<ExtractedData> extractedData = new ArrayList<>();

            for (JsonElement element : jsonArray) {
                JsonObject item = element.getAsJsonObject();
                ExtractedData extractedItem = new ExtractedData();

                // Obtenir la dernière transaction
                if (item.has("transactions") && item.get("transactions").isJsonArray()) {
                    JsonArray transactions = item.getAsJsonArray("transactions");
                    if (transactions.size() > 0) {
                        JsonObject lastTx = transactions.get(transactions.size() - 1).getAsJsonObject();
                        
                        if (lastTx.has("reference")) {
                            extractedItem.reference = lastTx.get("reference").getAsString();
                        }
                        
                        if (lastTx.has("dateCreated")) {
                            String dateStr = lastTx.get("dateCreated").getAsString();
                            
                            // Convertir la date au format AAAA-MM-JJ
                            if (dateStr.contains("T")) {
                                extractedItem.transactionDate = dateStr.split("T")[0];
                            } else {
                                try {
                                    LocalDate date = LocalDate.parse(dateStr);
                                    extractedItem.transactionDate = date.format(DateTimeFormatter.ISO_LOCAL_DATE);
                                } catch (DateTimeParseException e) {
                                    extractedItem.transactionDate = dateStr;
                                }
                            }
                        }
                    }
                }

                // Extraire l'email du client
                if (item.has("customer") && item.get("customer").isJsonObject()) {
                    JsonObject customer = item.getAsJsonObject("customer");
                    if (customer.has("email")) {
                        extractedItem.email = customer.get("email").getAsString();
                    }
                }

                // Extraire les données des options
                if (item.has("lineItems") && item.get("lineItems").isJsonArray()) {
                    JsonArray lineItems = item.getAsJsonArray("lineItems");
                    if (lineItems.size() > 0) {
                        JsonObject lineItem = lineItems.get(0).getAsJsonObject();
                        if (lineItem.has("options") && lineItem.get("options").isJsonObject()) {
                            JsonObject options = lineItem.getAsJsonObject("options");
                            
                            if (options.has("prenom")) {
                                extractedItem.prenom = options.get("prenom").getAsString();
                            }
                            
                            if (options.has("nom")) {
                                extractedItem.nom = options.get("nom").getAsString();
                            }
                            
                            if (options.has("dateNaissance")) {
                                extractedItem.dateNaissance = options.get("dateNaissance").getAsString();
                            }
                            
                            if (options.has("donationAmount")) {
                                extractedItem.donationAmount = options.get("donationAmount").getAsString();
                            }
                        }
                    }
                }

                // Filtrer par année si spécifiée
                if (filterYear != null && !filterYear.isEmpty()) {
                    if (extractedItem.transactionDate.length() >= 4) {
                        String year = extractedItem.transactionDate.substring(0, 4);
                        if (year.equals(filterYear)) {
                            extractedData.add(extractedItem);
                        }
                    }
                } else {
                    extractedData.add(extractedItem);
                }
            }

            return extractedData;
        }

        /**
         * Convertit les données en format CSV et les écrit dans un fichier
         *
         * @param data Liste des données extraites
         * @param outputFile Chemin du fichier de sortie
         * @throws IOException Si une erreur survient lors de l'écriture
         */
        public void convertToCSV(List<ExtractedData> data, String outputFile) throws IOException {
            BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFile), StandardCharsets.UTF_8);
            
            // En-têtes CSV
            String[] header = {"reference", "email", "prenom", "nom", "dateNaissance", "donationAmount", "transactionDate"};
            
            // Écrire l'en-tête
            writer.write(formatCSVLine(header));
            writer.newLine();
            
            // Écrire les lignes de données
            for (ExtractedData item : data) {
                writer.write(formatCSVLine(item.toArray()));
                writer.newLine();
            }
            
            writer.flush();
            writer.close();
        }
        
        /**
         * Formate une ligne CSV avec échappement des guillemets selon RFC 4180
         *
         * @param values Les valeurs à formater
         * @return Ligne CSV formatée
         */
        private String formatCSVLine(String[] values) {
            StringBuilder line = new StringBuilder();
            
            for (int i = 0; i < values.length; i++) {
                if (i > 0) {
                    line.append(",");
                }
                
                // Échapper les guillemets et entourer chaque valeur de guillemets
                String value = values[i] != null ? values[i] : "";
                value = value.replace("\"", "\"\"");
                line.append("\"").append(value).append("\"");
            }
            
            return line.toString();
        }

        /**
         * Processus principal d'extraction et de conversion
         *
         * @param inputFilePath Chemin vers le fichier JSON d'entrée
         * @param outputFilePath Chemin vers le fichier CSV de sortie
         * @throws IOException Si une erreur survient lors du traitement
         */
        public void process(String inputFilePath, String outputFilePath) throws IOException {
            // Lire le fichier JSON
            String fileContent = Files.readString(Paths.get(inputFilePath), StandardCharsets.UTF_8);
            
            // Traiter le contenu JSON
            JsonArray jsonArray;
            try {
                jsonArray = JsonParser.parseString(fileContent).getAsJsonArray();
            } catch (JsonSyntaxException | IllegalStateException e) {
                // Si le JSON n'est pas un tableau, essayer de le traiter comme un objet unique
                try {
                    JsonObject singleObject = JsonParser.parseString(fileContent).getAsJsonObject();
                    jsonArray = new JsonArray();
                    jsonArray.add(singleObject);
                } catch (JsonSyntaxException | IllegalStateException e2) {
                    // Tenter de réparer en ajoutant des crochets
                    try {
                        jsonArray = JsonParser.parseString("[" + fileContent + "]").getAsJsonArray();
                    } catch (JsonSyntaxException | IllegalStateException e3) {
                        throw new IOException("Le fichier JSON est mal formé et ne peut pas être réparé automatiquement: " + e3.getMessage());
                    }
                }
            }
            
            // Extraire les données
            List<ExtractedData> extractedData = extractData(jsonArray);
            
            // Vérifier si des données ont été extraites
            if (extractedData.isEmpty()) {
                if (filterYear != null && !filterYear.isEmpty()) {
                    System.out.println("Aucune transaction trouvée pour l'année " + filterYear + ".");
                } else {
                    System.out.println("Aucune transaction trouvée.");
                }
                return;
            }
            
            // Convertir en CSV et écrire dans le fichier
            convertToCSV(extractedData, outputFilePath);
            
            System.out.println("Extraction réussie! Fichier CSV créé: " + outputFilePath);
            System.out.println("Nombre d'entrées traitées: " + extractedData.size());
            
            if (filterYear != null && !filterYear.isEmpty()) {
                System.out.println("Filtre appliqué: Année " + filterYear);
            }
        }
    }

    /**
     * Demande à l'utilisateur s'il veut écraser un fichier existant
     *
     * @param filePath Chemin du fichier existant
     * @return true si l'utilisateur veut écraser, false sinon
     */
    private static boolean askForOverwrite(String filePath) {
        System.out.print("Le fichier " + filePath + " existe déjà. Voulez-vous l'écraser ? (o/n) ");
        Scanner scanner = new Scanner(System.in);
        String response = scanner.nextLine().toLowerCase();
        return response.equals("o");
    }

    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("Usage: java TransibaseDGEQConverter <inputFile> <outputFile> [year]");
            System.out.println("  inputFile: Chemin vers le fichier JSON d'entrée");
            System.out.println("  outputFile: Chemin vers le fichier CSV de sortie");
            System.out.println("  year: (Optionnel) Année pour filtrer les transactions (format: YYYY)");
            System.exit(1);
        }
        
        String inputFilePath = args[0];
        String outputFilePath = args[1];
        String filterYear = args.length > 2 ? args[2] : null;
        
        // Vérifier que le fichier d'entrée existe
        if (!Files.exists(Paths.get(inputFilePath))) {
            System.out.println("Erreur: Le fichier d'entrée " + inputFilePath + " n'existe pas.");
            System.exit(1);
        }
        
        // Vérifier le format de l'année si spécifiée
        if (filterYear != null && !filterYear.isEmpty()) {
            if (!Pattern.matches("^\\d{4}$", filterYear)) {
                System.out.println("Erreur: L'année doit être au format YYYY (ex: 2023).");
                System.exit(1);
            }
        }
        
        // Vérifier si le fichier de sortie existe déjà
        if (Files.exists(Paths.get(outputFilePath))) {
            if (!askForOverwrite(outputFilePath)) {
                System.out.println("Opération annulée.");
                System.exit(0);
            }
        }
        
        try {
            // Créer une instance du convertisseur
            TransibaseConverter converter = new TransibaseConverter(filterYear);
            
            // Traiter les données
            converter.process(inputFilePath, outputFilePath);
        } catch (Exception e) {
            System.out.println("Erreur lors du traitement: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}