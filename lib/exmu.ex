defmodule Exmu do

  @default_opts [format: "xml", mu_bin_path: "/usr/bin/mu"]

  def search(mu_dir_path, query, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    abs_mu_dir_path = Path.expand(mu_dir_path)
    case System.cmd opts[:mu_bin_path], ["find", "--muhome=#{abs_mu_dir_path}", "--format=#{opts[:format]}", query] do
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
    case System.cmd "mu", ["find", "--muhome=#{abs_mu_dir_path}", "maildir:/#{folder}", "--format=#{opts[:format]}", ""] do
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
    case System.cmd "mu", ["index", "--maildir=#{abs_mailbox_path}", "--muhome=#{abs_mu_dir_path}"] do
      {_, 0} -> :ok
      {_, _} -> raise("Could not index #{abs_mu_dir_path} with muhome #{abs_mu_dir_path}")
    end
  end


  def clean_query(query) do
    query
      |> String.replace(";", "")
  end

end
