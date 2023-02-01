defmodule ElixirInternalCertification.Keyword.Queries.KeywordQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}

  def list_keywords_by_user(%User{id: user_id} = _user, search_query \\ nil) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> maybe_filter_by_search_query(search_query)
    |> order_by([k], desc: k.id)
  end

  def list_keywords_by_user_using_url(%User{id: user_id} = _user, search_query, search_query_type, search_query_target) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> maybe_filter_by_search_query_using_url(search_query, search_query_type, search_query_target)
    |> order_by([k], desc: k.id)
  end

  defp maybe_filter_by_search_query(query, nil), do: query

  defp maybe_filter_by_search_query(query, search_query),
    do: where(query, [k], ilike(k.title, ^"%#{search_query}%"))

  defp maybe_filter_by_search_query_using_url(query, nil, _search_query_type, _search_query_target), do: query

  defp maybe_filter_by_search_query_using_url(query, search_query, "partial_match", _search_query_target) do
    keyword_lookup_query = select(KeywordLookup, [kl], %{id: kl.id, keyword_id: kl.keyword_id, urls_of_adwords_advertisers_top_position: fragment("UNNEST(urls_of_adwords_advertisers_top_position)"), urls_of_non_adwords: fragment("UNNEST(urls_of_non_adwords)")})

    query
    |> join(:left, [k], kl in subquery(keyword_lookup_query), on: kl.keyword_id == k.id)
    |> where([_k, kl], ilike(kl.urls_of_adwords_advertisers_top_position, ^"%#{search_query}%"))
    |> or_where([_k, kl], ilike(kl.urls_of_non_adwords, ^"%#{search_query}%"))
    |> distinct(true)
  end

  defp maybe_filter_by_search_query_using_url(query, search_query, "exact_match", _search_query_target) do
    query
    |> join(:left, [k], kl in assoc(k, :keyword_lookup))
    |> where([_k, kl], ^search_query in kl.urls_of_adwords_advertisers_top_position)
    |> or_where([_k, kl], ^search_query in kl.urls_of_non_adwords)
    |> distinct(true)
  end
end
