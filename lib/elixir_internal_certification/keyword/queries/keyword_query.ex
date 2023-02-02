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

  def list_keywords_by_user_using_url(
        %User{id: user_id} = _user,
        search_query,
        search_query_type,
        search_query_target,
        number_of_occurrences,
        symbol_notation
      ) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> maybe_filter_by_search_query_using_url(
      search_query,
      search_query_type,
      search_query_target,
      number_of_occurrences,
      symbol_notation
    )
    |> order_by([k], desc: k.id)
  end

  defp maybe_filter_by_search_query(query, nil), do: query

  defp maybe_filter_by_search_query(query, search_query),
    do: where(query, [k], ilike(k.title, ^"%#{search_query}%"))

  defp maybe_filter_by_search_query_using_url(
         query,
         nil,
         _search_query_type,
         _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ),
       do: query

  defp maybe_filter_by_search_query_using_url(
         query,
         search_query,
         search_query_type,
         search_query_target,
         number_of_occurrences,
         symbol_notation
       ) do
    query
    |> search_conditions(
      search_query,
      search_query_type,
      search_query_target,
      number_of_occurrences,
      symbol_notation
    )
    |> distinct(true)
  end

  defp search_conditions(
         query,
         search_query,
         "partial_match" = search_query_type,
         "all" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ilike(kl.urls_of_adwords_advertisers_top_position, ^"%#{search_query}%"))
    |> or_where([_k, kl], ilike(kl.urls_of_non_adwords, ^"%#{search_query}%"))
  end

  defp search_conditions(
         query,
         search_query,
         "partial_match" = search_query_type,
         "urls_of_adwords_advertisers_top_position" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ilike(kl.urls_of_adwords_advertisers_top_position, ^"%#{search_query}%"))
  end

  defp search_conditions(
         query,
         search_query,
         "partial_match" = search_query_type,
         "urls_of_non_adwords" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ilike(kl.urls_of_non_adwords, ^"%#{search_query}%"))
  end

  defp search_conditions(
         query,
         search_query,
         "exact_match" = search_query_type,
         "all" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ^search_query in kl.urls_of_adwords_advertisers_top_position)
    |> or_where([_k, kl], ^search_query in kl.urls_of_non_adwords)
  end

  defp search_conditions(
         query,
         search_query,
         "exact_match" = search_query_type,
         "urls_of_adwords_advertisers_top_position" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ^search_query in kl.urls_of_adwords_advertisers_top_position)
  end

  defp search_conditions(
         query,
         search_query,
         "exact_match" = search_query_type,
         "urls_of_non_adwords" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ^search_query in kl.urls_of_non_adwords)
  end

  defp search_conditions(
         query,
         search_query,
         "occurrences" = search_query_type,
         "all" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, _kl], fragment("array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1", ^search_query) > 1)
    |> or_where([_k, _kl], fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) > 1)
  end

  defp search_conditions(
         query,
         search_query,
         "occurrences" = search_query_type,
         "urls_of_adwords_advertisers_top_position" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, _kl], fragment("array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1", ^search_query) > 1)
  end

  defp search_conditions(
         query,
         search_query,
         "occurrences" = search_query_type,
         "urls_of_non_adwords" = _search_query_target,
         _number_of_occurrences,
         _symbol_notation
       ) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, _kl], fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) > 1)
  end

  defp join_search_query(query, search_query_type) when search_query_type in ["partial_match", "occurrences"] do
    keyword_lookup_query =
      select(KeywordLookup, [kl], %{
        id: kl.id,
        keyword_id: kl.keyword_id,
        urls_of_adwords_advertisers_top_position:
          fragment("unnest(urls_of_adwords_advertisers_top_position)"),
        urls_of_non_adwords: fragment("unnest(urls_of_non_adwords)")
      })

    join(query, :left, [k], kl in subquery(keyword_lookup_query), on: kl.keyword_id == k.id)
  end

  defp join_search_query(query, "exact_match"),
    do: join(query, :left, [k], kl in assoc(k, :keyword_lookup))
end
