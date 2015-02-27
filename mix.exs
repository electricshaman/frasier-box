defmodule Exfbox.Mixfile do
  use Mix.Project

  def project do
    [app: :frabox,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger],
    mod: {FrasierBox, []}]
  end

  defp deps do
    [
      {:timex, "~> 0.13.3"}
    ]
  end
end
