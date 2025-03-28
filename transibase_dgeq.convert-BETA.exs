#!/usr/bin/env elixir
# coding: utf-8

defmodule Transibase.DGEQ do
  @moduledoc """
  Transibase 1.0 - Extracteur de données JSON vers CSV (Version Elixir)

  Ce script permet d'extraire des données spécifiques depuis les commandes Craft Commerce
  exportées en JSON et de les convertir en format CSV.

  @copyright 2025 Québec Studio
  @license GNU General Public License v3.0 (GPL-3.0)
  @author Québec Studio
  @version 1.0.0
  """

  @csv_headers ["reference", "email", "prenom", "nom", "dateNaissance", "donationAmount", "transactionDate"]

  defmodule ExtractedData do
    @moduledoc "Structure pour stocker les données extraites"

    defstruct reference: "",
              email: "",
              prenom: "",
              nom: "",
              date_naissance: "",
              donation_amount: "",
              transaction_date: ""

    @doc "Convertit la structure en Map pour CSV"
    def to_map(data) do
      %{
        "reference" => data.reference,
        "email" => data.email,
        "prenom" => data.prenom,
        "nom" => data.nom,
        "dateNaissance" => data.date_naissance,
        "donationAmount" => data.donation_amount,
        "transactionDate" => data.transaction_date
      }
    end
  end

  @doc """
  Extrait les données demandées du JSON avec filtrage par année optionnel.
  """
  def extract_data(json_data, filter_year \\ nil) do
    # S'assurer que json_data est une liste
    data_array = if is_list(json_data), do: json_data, else: [json_data]

    data_array
    |> Enum.map(fn item ->
      # Obtenir la dernière transaction
      last_transaction =
        case get_in(item, ["transactions"]) do
          transactions when is_list(transactions) and length(transactions) > 0 ->
            List.last(transactions)

          _ ->
            %{}
        end

      # Convertir la date de la transaction au format AAAA-MM-JJ
      transaction_date =
        case get_in(last_transaction, ["dateCreated"]) do
          nil ->
            ""

          date_str when is_binary(date_str) ->
            cond do
              String.contains?(date_str, "T") ->
                # Format ISO
                date_str |> String.split("T") |> List.first()

              true ->
                # Tenter de convertir la date
                try do
                  {:ok, date} = Date.from_iso8601(date_str)
                  Date.to_string(date)
                rescue
                  _ -> date_str
                end
            end

          _ ->
            ""
        end

      # Extraire les informations du client et des options
      email = get_in(item, ["customer", "email"]) || ""

      line_item = get_in(item, ["lineItems"]) |> List.first() || %{}
      options = get_in(line_item, ["options"]) || %{}

      prenom = options["prenom"] || ""
      nom = options["nom"] || ""
      date_naissance = options["dateNaissance"] || ""
      donation_amount = options["donationAmount"] || ""

      # Créer la structure des données extraites
      %ExtractedData{
        reference: last_transaction["reference"] || "",
        email: email,
        prenom: prenom,
        nom: nom,
        date_naissance: date_naissance,
        donation_amount: donation_amount,
        transaction_date: transaction_date
      }
    end)
    |> filter_by_year(filter_year)
  end

  @doc """
  Filtre les données par année si une année est spécifiée.
  """
  def filter_by_year(data, nil), do: data

  def filter_by_year(data, filter_year) do
    Enum.filter(data, fn item ->
      case item.transaction_date do
        "" ->
          false

        date_str ->
          year = String.slice(date_str, 0, 4)
          year == filter_year
      end
    end)
  end

  @doc """
  Convertit les données en format CSV et les écrit dans un fichier.
  """
  def convert_to_csv(data, output_file) do
    rows =
      data
      |> Enum.map(fn item ->
        item_map = ExtractedData.to_map(item)
        Enum.map(@csv_headers, fn header -> Map.get(item_map, header, "") end)
      end)

    file = File.open!(output_file, [:write, :utf8])

    # Écrire l'en-tête
    headers_line = @csv_headers |> Enum.map(&format_csv_field/1) |> Enum.join(",")
    IO.puts(file, headers_line)

    # Écrire les lignes de données
    Enum.each(rows, fn row ->
      line = row |> Enum.map(&format_csv_field/1) |> Enum.join(",")
      IO.puts(file, line)
    end)

    File.close(file)
  end

  @doc """
  Formate un champ CSV en échappant les guillemets et en entourant de guillemets.
  """
  def format_csv_field(value) when is_binary(value) do
    escaped_value = String.replace(value, "\"", "\"\"")
    "\"#{escaped_value}\""
  end

  def format_csv_field(nil), do: "\"\""
  def format_csv_field(value), do: format_csv_field(to_string(value))

  @doc """
  Processus principal d'extraction et de conversion.
  """
  def process(input_file_path, output_file_path, filter_year \\ nil) do
    # Lire le fichier JSON
    with {:ok, file_content} <- File.read(input_file_path) do
      # Traiter le contenu JSON
      json_data =
        try do
          Jason.decode!(file_content)
        rescue
          e in Jason.DecodeError ->
            # Si le JSON est mal formé, essayer de le réparer
            try do
              Jason.decode!("[#{file_content}]")
            rescue
              _ ->
                raise "Le fichier JSON est mal formé et ne peut pas être réparé automatiquement: #{e.message}"
            end
        end

      # Extraire les données
      extracted_data = extract_data(json_data, filter_year)

      # Vérifier si des données ont été extraites
      if Enum.empty?(extracted_data) do
        if filter_year do
          IO.puts("Aucune transaction trouvée pour l'année #{filter_year}.")
        else
          IO.puts("Aucune transaction trouvée.")
        end
      else
        # Convertir en CSV et écrire dans le fichier
        convert_to_csv(extracted_data, output_file_path)

        IO.puts("Extraction réussie! Fichier CSV créé: #{output_file_path}")
        IO.puts("Nombre d'entrées traitées: #{length(extracted_data)}")

        if filter_year do
          IO.puts("Filtre appliqué: Année #{filter_year}")
        end
      end
    else
      {:error, reason} ->
        raise "Impossible de lire le fichier d'entrée: #{reason}"
    end
  end

  @doc """
  Demande à l'utilisateur s'il veut écraser un fichier existant.
  """
  def ask_for_overwrite(file_path) do
    IO.write("Le fichier #{file_path} existe déjà. Voulez-vous l'écraser ? (o/n) ")
    response = IO.gets("") |> String.trim() |> String.downcase()
    response == "o"
  end
end

# Point d'entrée du script
if System.argv() |> length() < 2 do
  IO.puts("Usage: elixir transibase_dgeq_convert.exs <inputFile> <outputFile> [year]")
  IO.puts("  inputFile: Chemin vers le fichier JSON d'entrée")
  IO.puts("  outputFile: Chemin vers le fichier CSV de sortie")
  IO.puts("  year: (Optionnel) Année pour filtrer les transactions (format: YYYY)")
  System.halt(1)
end

[input_file_path, output_file_path | rest] = System.argv()
filter_year = List.first(rest)

# Vérifier que le fichier d'entrée existe
unless File.exists?(input_file_path) do
  IO.puts("Erreur: Le fichier d'entrée #{input_file_path} n'existe pas.")
  System.halt(1)
end

# Vérifier le format de l'année si spécifiée
if filter_year && not Regex.match?(~r/^\d{4}$/, filter_year) do
  IO.puts("Erreur: L'année doit être au format YYYY (ex: 2023).")
  System.halt(1)
end

# Vérifier si le fichier de sortie existe déjà
if File.exists?(output_file_path) do
  unless Transibase.DGEQ.ask_for_overwrite(output_file_path) do
    IO.puts("Opération annulée.")
    System.halt(0)
  end
end

try do
  # Traiter les données
  Transibase.DGEQ.process(input_file_path, output_file_path, filter_year)
rescue
  e ->
    IO.puts("Erreur lors du traitement: #{Exception.message(e)}")
    System.halt(1)
end
