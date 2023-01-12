defmodule ElixirInternalCertification.Keyword.Queries.KeywordQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  def list_keywords_by_user(%User{id: user_id} = _user, search_query \\ nil) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> maybe_filter_by_search_query(search_query)
    |> order_by([k], desc: k.id)
  end

  defp maybe_filter_by_search_query(query, nil), do: query

  defp maybe_filter_by_search_query(query, search_query),
    do: where(query, [k], ilike(k.title, ^"%#{search_query}%"))
end
