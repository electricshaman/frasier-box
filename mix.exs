defmodule Exfbox.Mixfile do
  use Mix.Project

  def project do
    [app: :frabox,
     version: "0.0.2",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :timex],
    mod: {FrasierBox, []}]
  end

  defp deps do
    [
      {:timex, "~> 0.13.3"},
      {:exrm, "~> 0.15.3"}
    ]
  end
end
