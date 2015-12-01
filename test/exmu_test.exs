defmodule ExmuTest do
  use ExUnit.Case
  doctest Exmu

  setup do
    Exmu.TestHelpers.restore_from_backup
    :ok
  end


  test "index emails" do
    mailbox_path = "test/mails/testing.com/abc/"
    mu_dir_path  = "test/mails/testing.com/abc/.mu"
    assert :ok == Exmu.index_emails(mailbox_path, mu_dir_path)
    assert File.exists?(mu_dir_path)
  end


  test "read_folder" do
    mailbox_path = "test/mails/testing.com/abc/"
    mu_dir_path  = "test/mails/testing.com/abc/.mu"
    :ok = Exmu.index_emails(mailbox_path, mu_dir_path)
    {:ok, res} = Exmu.read_folder(mu_dir_path, "INBOX", format: "plain")
    assert Enum.count(res) == 2
    {:ok, res} = Exmu.read_folder(mu_dir_path, "", format: "plain")
    assert Enum.count(res) == 6
  end


  test "search" do
    mailbox_path = "test/mails/testing.com/abc/"
    mu_dir_path  = "test/mails/testing.com/abc/.mu"
    :ok = Exmu.index_emails(mailbox_path, mu_dir_path)
    {:ok, res} = Exmu.search(mu_dir_path, "tgv", format: "plain")
    assert Enum.count(res) == 1
  end


  test "search 2" do
    mailbox_path = "test/mails/testing.com/abc/"
    mu_dir_path  = "test/mails/testing.com/abc/.mu"
    :ok = Exmu.index_emails(mailbox_path, mu_dir_path)
    {:ok, res} = Exmu.search(mu_dir_path, "tgv", format: "plain")
    assert Enum.count(res) == 1
  end


  test "contacts" do
    mailbox_path = "test/mails/testing.com/abc/"
    mu_dir_path  = "test/mails/testing.com/abc/.mu"
    :ok = Exmu.index_emails(mailbox_path, mu_dir_path)
    res = Exmu.contacts(mu_dir_path, "", format: "plain")
    res_splitted = String.split(res, "\n")
    assert Enum.count(res_splitted) == 11
    assert Enum.member?(res_splitted, "Hans Huber blue@tester")
  end

end
