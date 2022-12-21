defmodule ElixirInternalCertification.GoogleHelper do
  @fixture_path "test/support/fixtures"

  def get_html_of_search_results(query),
    do: File.read!(Path.join([@fixture_path, "assets/google", "#{query}.html"]))
end
