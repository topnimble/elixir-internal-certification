defmodule ElixirInternalCertificationWeb.KeywordLive.Index do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Keywords
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
  def handle_info({:updated, keyword} = _message, %Socket{assigns: %{keywords: keywords}} = socket),
    do: {:noreply, assign(socket, :keywords, Keywords.find_and_update_keyword(keywords, keyword))}

  @impl true
  def handle_event(
        "change_search_query",
        %{"search_box" => %{"query" => query}} = _unsigned_params,
        socket
      ) do
    url = generate_url_with_query(socket, query)
    socket = push_patch(socket, to: url)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "submit_search_query",
        %{"search_box" => %{"query" => query}} = _unsigned_params,
        socket
      ) do
    url = generate_url_with_query(socket, query)
    socket = push_redirect(socket, to: url)
    {:noreply, socket}
  end

  defp generate_url_with_query(socket, query) do
    case query do
      "" -> Routes.keyword_index_path(socket, :index)
      _ -> Routes.keyword_index_path(socket, :index, query: query)
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Keywords")
    |> assign_keywords()
  end

  defp assign_keywords(socket),
    do:
      assign(
        socket,
        :keywords,
        socket
        |> LiveHelpers.get_current_user_from_socket()
        |> list_keywords()
      )

  defp list_keywords(%User{} = user), do: Keywords.list_keywords(user)
end
