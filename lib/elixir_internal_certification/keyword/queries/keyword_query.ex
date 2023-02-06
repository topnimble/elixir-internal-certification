defmodule ElixirInternalCertification.Keyword.Queries.KeywordQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Queries.KeywordLookupQuery
  alias ElixirInternalCertification.Keyword.Schemas.{AdvancedSearch, Keyword}

  def list_keywords_by_user(%User{} = user, search_query \\ nil) do
    Keyword
    |> from_search_params(user, search_query)
    |> order_by([k], desc: k.id)
  end

  def list_keywords_by_user_for_advanced_search(%User{} = user, advanced_search_params) do
    Keyword
    |> from_advanced_search_params(user, advanced_search_params)
    |> order_by([k], desc: k.id)
  end

  defp from_search_params(query, %User{id: user_id} = _user, nil),
    do: where(query, [k], k.user_id == ^user_id)

  defp from_search_params(query, %User{id: user_id} = _user, search_query) do
    query
    |> where([k], k.user_id == ^user_id)
    |> where([k], ilike(k.title, ^"%#{search_query}%"))
  end

  defp from_advanced_search_params(
         query,
         %User{id: user_id} = _user,
         %AdvancedSearch{search_query: nil} = _advanced_search_params
       ),
       do: where(query, [k], k.user_id == ^user_id)

  defp from_advanced_search_params(
         query,
         %User{id: user_id} = user,
         advanced_search_params
       ) do
    keyword_lookup_query =
      KeywordLookupQuery.from_advanced_search_params(user, advanced_search_params)

    query
    |> join(:inner, [k], kl in subquery(keyword_lookup_query), on: kl.keyword_id == k.id)
    |> where([k], k.user_id == ^user_id)
    |> distinct(true)
  end
end
