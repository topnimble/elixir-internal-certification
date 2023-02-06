defmodule ElixirInternalCertification.Keyword.Queries.KeywordLookupQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.{AdvancedSearch, KeywordLookup}

  def from_advanced_search_params(
        query \\ KeywordLookup,
        %User{id: user_id} = _user,
        advanced_search_params
      ) do
    query
    |> join(:inner, [kl], k in assoc(kl, :keyword), on: k.user_id == ^user_id)
    |> condition_query(advanced_search_params)
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "partial_match",
         search_query_target: "all"
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where([kl], ilike(fragment("url_of_adwords_advertisers_top_position"), ^"%#{search_query}%"))
    |> or_where([kl], ilike(fragment("url_of_non_adwords"), ^"%#{search_query}%"))
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "partial_match",
         search_query_target: "urls_of_adwords_advertisers_top_position"
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where([kl], ilike(fragment("url_of_adwords_advertisers_top_position"), ^"%#{search_query}%"))
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "partial_match",
         search_query_target: "urls_of_non_adwords"
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where([kl], ilike(fragment("url_of_non_adwords"), ^"%#{search_query}%"))
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "exact_match",
         search_query_target: "all"
       }) do
    query
    |> where([kl], ^search_query in kl.urls_of_adwords_advertisers_top_position)
    |> or_where([kl], ^search_query in kl.urls_of_non_adwords)
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "exact_match",
         search_query_target: "urls_of_adwords_advertisers_top_position"
       }),
       do: where(query, [kl], ^search_query in kl.urls_of_adwords_advertisers_top_position)

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "exact_match",
         search_query_target: "urls_of_non_adwords"
       }),
       do: where(query, [kl], ^search_query in kl.urls_of_non_adwords)

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "all",
         symbol_notation: ">",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) > ^number_of_occurrences
    )
    |> or_where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) > ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "all",
         symbol_notation: ">=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) >= ^number_of_occurrences
    )
    |> or_where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) >= ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "all",
         symbol_notation: "<",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) < ^number_of_occurrences
    )
    |> or_where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) < ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "all",
         symbol_notation: "<=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) <= ^number_of_occurrences
    )
    |> or_where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) <= ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "all",
         symbol_notation: "=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) == ^number_of_occurrences
    )
    |> or_where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) == ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: ">",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) > ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: ">=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) >= ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: "<",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) < ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: "<=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) <= ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_adwords_advertisers_top_position",
         symbol_notation: "=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_adwords_advertisers_top_position, ?), 1) - 1",
        ^search_query
      ) == ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_non_adwords",
         symbol_notation: ">",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) > ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_non_adwords",
         symbol_notation: ">=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) >= ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_non_adwords",
         symbol_notation: "<",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) < ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_non_adwords",
         symbol_notation: "<=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) <= ^number_of_occurrences
    )
  end

  defp condition_query(query, %AdvancedSearch{
         search_query: search_query,
         search_query_type: "occurrences",
         search_query_target: "urls_of_non_adwords",
         symbol_notation: "=",
         number_of_occurrences: number_of_occurrences
       }) do
    query
    |> with_cte("keyword_lookup_cte",
      as:
        fragment(
          "select id, unnest(urls_of_adwords_advertisers_top_position) as url_of_adwords_advertisers_top_position, unnest(urls_of_non_adwords) as url_of_non_adwords from keyword_lookups"
        )
    )
    |> join(:left, [kl], klc in "keyword_lookup_cte", on: klc.id == kl.id)
    |> select_merge([kl], %{
      url_of_adwords_advertisers_top_position: fragment("url_of_adwords_advertisers_top_position"),
      url_of_non_adwords: fragment("url_of_non_adwords")
    })
    |> where(
      [kl],
      fragment(
        "array_length(string_to_array(url_of_non_adwords, ?), 1) - 1",
        ^search_query
      ) == ^number_of_occurrences
    )
  end

  defp condition_query(query, _advanced_search_params), do: query
end
