defmodule ElixirInternalCertification.Keyword.Queries.KeywordQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Queries.KeywordLookupQuery
  alias ElixirInternalCertification.Keyword.Schemas.{AdvancedSearch, Keyword}

  def list_keywords_by_user(%User{id: user_id} = _user, search_query \\ nil) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> maybe_filter_by_search_query(search_query)
    |> order_by([k], desc: k.id)
  end

  def list_keywords_by_user_for_advanced_search(%User{id: user_id} = user, advanced_search_params) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> maybe_filter_by_search_query_for_advanced_search(user, advanced_search_params)
    |> order_by([k], desc: k.id)
  end

  defp maybe_filter_by_search_query(query, nil), do: query

  defp maybe_filter_by_search_query(query, search_query),
    do: where(query, [k], ilike(k.title, ^"%#{search_query}%"))

  defp maybe_filter_by_search_query_for_advanced_search(
         query,
         %User{} = _user,
         %AdvancedSearch{search_query: nil} = _advanced_search_params
       ),
       do: query

  defp maybe_filter_by_search_query_for_advanced_search(
         query,
         %User{} = user,
         advanced_search_params
       ) do
    keyword_lookup_query =
      KeywordLookupQuery.from_advanced_search_params(user, advanced_search_params)

    query
    |> join(:inner, [k], kl in subquery(keyword_lookup_query), on: kl.keyword_id == k.id)
    |> distinct(true)
  end
end
