# Exmu

** Small wrapper to [mu](https://github.com/djcb/mu)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exmu to your list of dependencies in `mix.exs`:

        def deps do
          [{:exmu, "~> 0.0.1"}]
        end

  2. Ensure exmu is started before your application:

        def application do
          [applications: [:exmu]]
        end

## Usage

First you need to index the emails and generate the mu xapian database. The database will
automatically be created in that directory.

    Exmu.index_emails("path/to/emails", "path/to/mu/xapian/database")

Then you can search your emails.

    Exmu.search("path/to/mu/xapian/database", "love")


The default format in which the results are returned is xml. If you prefer json,
you need to install our custom mu client from here: (mu)[https://github.com/migadu/mu].
Then you can get json responses by

    Exmu.search("path/to/mu/xapian/database", "love", format: "json")


If you don't have mu in /usr/bin/mu, you can also pass it via the option mu_bin_path:

    Exmu.search("path/to/mu/xapian/database", "love", mu_bin_path: "/path/to/mu/executable")
