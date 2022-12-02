defmodule ElixirInternalCertification.KeywordsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ElixirInternalCertification.Keyword.Keywords` context.
  """

  @doc """
  Generate a keyword.
  """
  def keyword_fixture(attrs \\ %{}) do
    {:ok, keyword} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> ElixirInternalCertification.Keyword.Keywords.create_keyword()

    keyword
  end
end
