defmodule ElixirInternalCertification.Keyword.Queries.KeywordQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.{AdvancedSearch, Keyword, KeywordLookup}

  def list_keywords_by_user(%User{id: user_id} = _user, search_query \\ nil) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> maybe_filter_by_search_query(search_query)
    |> order_by([k], desc: k.id)
  end

  def list_keywords_by_user_for_advanced_search(%User{id: user_id} = _user, advanced_search_params) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> maybe_filter_by_search_query_for_advanced_search(advanced_search_params)
    |> order_by([k], desc: k.id)
  end

  defp maybe_filter_by_search_query(query, nil), do: query

  defp maybe_filter_by_search_query(query, search_query),
    do: where(query, [k], ilike(k.title, ^"%#{search_query}%"))

  defp maybe_filter_by_search_query_for_advanced_search(
         query,
         %AdvancedSearch{search_query: nil} = _advanced_search_params
       ),
       do: query

  defp maybe_filter_by_search_query_for_advanced_search(query, advanced_search_params) do
    query
    |> search_conditions(advanced_search_params)
    |> distinct(true)
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "partial_match" = search_query_type,
         search_query_target: "all"
       }) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ilike(kl.urls_of_adwords_advertisers_top_position, ^"%#{search_query}%"))
    |> or_where([_k, kl], ilike(kl.urls_of_non_adwords, ^"%#{search_query}%"))
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "partial_match" = search_query_type,
         search_query_target: "urls_of_adwords_advertisers_top_position"
       }) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ilike(kl.urls_of_adwords_advertisers_top_position, ^"%#{search_query}%"))
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "partial_match" = search_query_type,
         search_query_target: "urls_of_non_adwords"
       }) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ilike(kl.urls_of_non_adwords, ^"%#{search_query}%"))
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "exact_match" = search_query_type,
         search_query_target: "all"
       }) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ^search_query in kl.urls_of_adwords_advertisers_top_position)
    |> or_where([_k, kl], ^search_query in kl.urls_of_non_adwords)
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "exact_match" = search_query_type,
         search_query_target: "urls_of_adwords_advertisers_top_position"
       }) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ^search_query in kl.urls_of_adwords_advertisers_top_position)
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "exact_match" = search_query_type,
         search_query_target: "urls_of_non_adwords"
       }) do
    query
    |> join_search_query(search_query_type)
    |> where([_k, kl], ^search_query in kl.urls_of_non_adwords)
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "all",
         symbol_notation: ">",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) > ^number_of_occurrences
    )
    |> or_where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) >
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "all",
         symbol_notation: ">=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) >= ^number_of_occurrences
    )
    |> or_where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) >=
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "all",
         symbol_notation: "<",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) < ^number_of_occurrences
    )
    |> or_where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) <
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "all",
         symbol_notation: "<=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) <= ^number_of_occurrences
    )
    |> or_where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) <=
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "all",
         symbol_notation: "=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) == ^number_of_occurrences
    )
    |> or_where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) ==
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: ">",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) > ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: ">=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) >= ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: "<",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) < ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: "<=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) <= ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: "=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment(
        "array_length(string_to_array(urls_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) == ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_non_adwords",
         symbol_notation: ">",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) >
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_non_adwords",
         symbol_notation: ">=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) >=
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_non_adwords",
         symbol_notation: "<",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) <
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_non_adwords",
         symbol_notation: "<=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) <=
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences" = search_query_type,
         search_query_target: "urls_of_non_adwords",
         symbol_notation: "=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> join_search_query(search_query_type)
    |> where(
      [_k, _kl],
      fragment("array_length(string_to_array(urls_of_non_adwords, ?), 1) - 1", ^search_query) ==
        ^number_of_occurrences
    )
  end

  defp search_conditions(query, _advanced_search_params), do: query

  defp join_search_query(query, search_query_type)
       when search_query_type in ["partial_match", "occurrences"] do
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
