defmodule ElixirInternalCertificationWeb.AdvancedSearchLive.Index do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.{AdvancedSearch, Keyword}
  alias ElixirInternalCertificationWeb.LiveComponents.KeywordRowComponent
  alias ElixirInternalCertificationWeb.LiveHelpers
  alias Phoenix.LiveView.Socket

  @default_number_of_occurrences 0
  @default_symbol_notation ">"

  @impl true
  def mount(_params, session, socket) do
    socket = LiveHelpers.set_current_user_to_socket(socket, session)

    if connected?(socket) do
      socket
      |> LiveHelpers.get_current_user_from_socket()
      |> Keywords.subscribe_keyword_update()
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl true
  def handle_info(
        {:updated, %Keyword{id: keyword_id} = _keyword} = _message,
        %Socket{assigns: %{keywords: keywords}} = socket
      ),
      do:
        {:noreply,
         assign(socket, :keywords, Keywords.find_and_update_keyword(keywords, keyword_id))}

  @impl true
  def handle_event("change_search_query", %{"search_form" => search_form} = _unsigned_params, socket) do
    url = generate_url_with_search_query(socket, search_form)

    socket = push_patch(socket, to: url)
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit_search_query", %{"search_form" => search_form} = _unsigned_params, socket) do
    url = generate_url_with_search_query(socket, search_form)

    socket = push_redirect(socket, to: url)
    {:noreply, socket}
  end

  defp generate_url_with_search_query(
         socket,
         search_form
       ) do
    Routes.advanced_search_index_path(socket, :index,
      query: search_form["search_query"],
      query_type: search_form["search_query_type"],
      query_target: search_form["search_query_target"],
      number_of_occurrences: search_form["number_of_occurrences"],
      symbol_notation: search_form["symbol_notation"]
    )
  end

  defp apply_action(socket, :index, params) do
    search_query = params["query"]
    search_query_type = params["query_type"]
    search_query_target = params["query_target"]
    number_of_occurrences = case params["number_of_occurrences"] do
      "" -> @default_number_of_occurrences
      nil -> @default_number_of_occurrences
      number_of_occurrences -> String.to_integer(number_of_occurrences)
    end
    symbol_notation = case params["symbol_notation"] do
      "" -> @default_symbol_notation
      nil -> @default_symbol_notation
      symbol_notation -> symbol_notation
    end

    advanced_search_params = AdvancedSearch.new(%{
      "search_query" => search_query,
      "search_query_type" => search_query_type,
      "search_query_target" => search_query_target,
      "number_of_occurrences" => number_of_occurrences,
      "symbol_notation" => symbol_notation
    })

    socket
    |> assign(:page_title, "Listing Keywords")
    |> assign(:search_query, search_query)
    |> assign(:search_query_type, search_query_type)
    |> assign(:search_query_target, search_query_target)
    |> assign(:number_of_occurrences, number_of_occurrences)
    |> assign(:symbol_notation, symbol_notation)
    |> assign_keywords(advanced_search_params)
  end

  defp assign_keywords(socket, params) do
    assign(
      socket,
      :keywords,
      socket
      |> LiveHelpers.get_current_user_from_socket()
      |> list_keywords(params)
    )
  end

  defp list_keywords(%User{} = user, params), do: Keywords.list_keywords_for_advanced_search(user, params)
end
