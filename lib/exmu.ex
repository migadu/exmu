defmodule Exmu do

  @default_opts [format: "xml", mu_bin_path: "/usr/local/bin/mu",
                sortfield: "date", maxnum: 10000, other_mu_opts: ""]

  def search(mu_dir_path, query, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    abs_mu_dir_path = Path.expand(mu_dir_path)
    mu_executable = opts[:mu_bin_path]
    if query == "", do: query = "''"
    command = ["find", "--muhome=#{abs_mu_dir_path}", "--format=#{opts[:format]}", "--maxnum=#{opts[:maxnum]}", "--sortfield=#{opts[:sortfield]}", opts[:other_mu_opts], query]
    if opts[:debug] do
      IO.puts "--- EXMU Debug Search ---"
      IO.puts "#{mu_executable} #{Enum.join(command, " ")}"
    end

    case :erlsh.run(to_char_list("#{mu_executable} #{Enum.join(command, " ")}")) do
      {:done, 0, res} ->
        case opts[:format] do
          "xml" -> {:ok, to_string(res) |> String.strip}
          "plain" -> {:ok, to_string(res) |> String.strip |> String.split("\n")}
          "json" -> {:ok, to_string(res) |> String.strip |> String.split("\n")}
        end
      {:done, 2, res} -> # Wrong command
        case opts[:format] do
          "xml" -> IO.puts res; {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<messages></messages>"}
          "plain" -> IO.puts res; {:ok, ""}
          "json" -> IO.puts res; {:ok, "[]"}
        end
      {:done, 4, res} -> # No results found
        case opts[:format] do
          "xml" -> {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<messages></messages>"}
          "plain" -> {:ok, ""}
          "json" -> {:ok, "[]"}
        end
      {err, error_code, error_msg} -> IO.inspect err: err, error_code: error_code, error_msg: error_msg; {:error, []}
    end
  end


  def read_folder(mu_dir_path, folder, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    abs_mu_dir_path = Path.expand(mu_dir_path)
    mu_executable = opts[:mu_bin_path]
    command = ["find", "--muhome=#{abs_mu_dir_path}", "maildir:#{folder}", "--format=#{opts[:format]}", "--sortfield=#{opts[:sortfield]}", "--reverse", "--maxnum=#{opts[:maxnum]}", ""]
    if opts[:debug] do
      IO.puts "--- EXMU Debug Read Folder---"
      IO.puts "#{mu_executable} #{Enum.join(command, " ")}"
    end
    case :erlsh.run(to_char_list("#{mu_executable} #{Enum.join(command, " ")}")) do
      {:done, 0, res} ->
        case opts[:format] do
          "xml"   -> {:ok, to_string(res) |> String.strip}
          "plain" -> {:ok, to_string(res) |> String.strip |> String.split("\n")}
          "json"  -> {:ok, to_string(res) |> String.strip |> String.split("\n")}
        end
      {:done, 4, res} -> # No results found
        case opts[:format] do
          "xml"   -> {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<messages></messages>"}
          "plain" -> {:ok, ""}
          "json"  -> {:ok, "[]"}
        end
      {_, _, _} -> {:error, "[]"}
    end
  end


  def index_emails(mailbox_path, mu_dir_path, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    abs_mailbox_path = Path.expand(mailbox_path)
    abs_mu_dir_path = Path.expand(mu_dir_path)
    mu_executable = opts[:mu_bin_path]
    command = ["index", "--maildir=#{abs_mailbox_path}", "--muhome=#{abs_mu_dir_path}", opts[:other_mu_opts]]
    if opts[:debug] do
      IO.puts "--- EXMU Debug Index ---"
      IO.puts "#{mu_executable} #{Enum.join(command, " ")}"
    end
    :ok = File.mkdir_p abs_mu_dir_path
    case :erlsh.oneliner(to_char_list("#{mu_executable} #{Enum.join(command, " ")}")) do
      {:done, 0, res} -> :ok
      {err, error_code, error_msg} -> IO.inspect err: err, error_code: error_code, error_msg: error_msg; :error
    end
  end


  def contacts(mu_dir_path, query \\ "", opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    abs_mu_dir_path = Path.expand(mu_dir_path)
    mu_executable = opts[:mu_bin_path]
    case System.cmd mu_executable, ["cfind", "--muhome=#{abs_mu_dir_path}", "--format=#{opts[:format]}", query] do
      {res, 0} -> res
      {_, 1} -> raise("Error with cfind. Mu index dir: #{abs_mu_dir_path}.")
      {_, x} -> IO.puts("Error #{x} in fetching contacts"); "[]"
    end
  end


  def clean_query(query) do
    query
      |> String.replace(";", "")
  end


  @doc """
  Returns the name of the folder on the server.
  """
  def folder_mapping(foldername) do
    case foldername |> String.downcase do
      # Inbox is on top directory in dovecot
      ".inbox"   -> ""
      "inbox"    -> ""
      ".Inbox"   -> "."
      # "drafts"  -> ".Drafts"
      ".drafts"  -> "draft"
      # "draft"   -> ".Drafts"
      # "Draft"   -> ".Drafts"
      # "spam"    -> ".Junk"
      # "Spam"    -> ".Junk"
      # "junk"    -> ".Junk"
      # "Junk"    -> ".Junk"
      # "sent"    -> ".Sent"
      # "Sent"    -> ".Sent"
      # "trash"   -> ".Trash"
      # "Trash"   -> ".Trash"
      # "archive" -> ".Archive"
      # "Archive" -> ".Archive"
      "."       -> "." # if we simply want the mailbox path
      other  ->  foldername
    end
  end


end
