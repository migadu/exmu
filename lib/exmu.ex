defmodule Exmu do

  @default_opts [format: "xml", mu_bin_path: "/usr/local/bin/mu", sortfield: "date"]

  def search(mu_dir_path, query, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    abs_mu_dir_path = Path.expand(mu_dir_path)
    mu_executable = opts[:mu_bin_path]
    case System.cmd mu_executable, ["find", "--muhome=#{abs_mu_dir_path}", "--format=#{opts[:format]}", "--sortfield=#{opts[:sortfield]}", "--reverse", "--maxnum=100", query] do
      {res, 0} ->
        case opts[:format] do
          "xml" -> {:ok, res |> String.strip}
          "plain" -> {:ok, res |> String.strip |> String.split("\n")}
          "json" -> {:ok, res |> String.strip |> String.split("\n")}
        end
      {res, _} -> {:error, []}
    end
  end


  def read_folder(mu_dir_path, folder, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    abs_mu_dir_path = Path.expand(mu_dir_path)
    mu_executable = opts[:mu_bin_path]
    command = ["find", "--muhome=#{abs_mu_dir_path}", "maildir:/#{folder}", "--format=#{opts[:format]}", "--sortfield=#{opts[:sortfield]}", "--reverse", "--maxnum=100", ""]
    IO.puts Enum.join(command, " ")
    case System.cmd mu_executable, command do
      {res, 0} ->
        case opts[:format] do
          "xml" -> {:ok, res |> String.strip }
          "plain" -> {:ok, res |> String.strip |> String.split("\n")}
          "json" -> {:ok, res |> String.strip |> String.split("\n")}
        end
      {res, _} -> {:error, []}
    end
  end


  def index_emails(mailbox_path, mu_dir_path, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    abs_mailbox_path = Path.expand(mailbox_path)
    abs_mu_dir_path = Path.expand(mu_dir_path)
    mu_executable = opts[:mu_bin_path]
    :ok = File.mkdir_p abs_mu_dir_path
    case System.cmd mu_executable, ["index", "--maildir=#{abs_mailbox_path}", "--muhome=#{abs_mu_dir_path}"] do
      {_, 0} -> :ok
      {_, _} -> raise("Could not index #{abs_mu_dir_path} with muhome #{abs_mu_dir_path}")
    end
  end


  def clean_query(query) do
    query
      |> String.replace(";", "")
  end


  @doc """
  Returns the name of the folder on the server.
  ## Examples
      iex> Migadu.Manager.Webmail.Api.folder_mapping("Spam")
      .Junk
      iex> Migadu.Manager.Webmail.Api.folder_mapping("Inbox")
      .
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
