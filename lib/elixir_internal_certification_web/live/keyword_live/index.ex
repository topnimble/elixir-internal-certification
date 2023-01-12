defmodule ElixirInternalCertificationWeb.KeywordLive.Index do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertificationWeb.LiveHelpers
  alias Phoenix.LiveView.Socket

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
  def handle_event(
        "change_search_query",
        %{"search_box" => %{"search_query" => search_query}} = _unsigned_params,
        socket
      ) do
    url = generate_url_with_search_query(socket, search_query)
    socket = push_patch(socket, to: url)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "submit_search_query",
        %{"search_box" => %{"search_query" => search_query}} = _unsigned_params,
        socket
      ) do
    url = generate_url_with_search_query(socket, search_query)
    socket = push_redirect(socket, to: url)
    {:noreply, socket}
  end

  defp generate_url_with_search_query(socket, search_query) do
    case search_query do
      "" -> Routes.keyword_index_path(socket, :index)
      _ -> Routes.keyword_index_path(socket, :index, query: search_query)
    end
  end

  defp apply_action(socket, :index, params) do
    search_query = params["query"]

    socket
    |> assign(:page_title, "Listing Keywords")
    |> assign(:search_query, search_query)
    |> assign_keywords(search_query)
  end

  defp assign_keywords(socket, search_query) do
    assign(
      socket,
      :keywords,
      socket
      |> LiveHelpers.get_current_user_from_socket()
      |> list_keywords(search_query)
    )
  end

  defp list_keywords(%User{} = user, search_query), do: Keywords.list_keywords(user, search_query)
end
