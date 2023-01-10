defmodule ElixirInternalCertificationWeb.KeywordLive.Index do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertificationWeb.LiveHelpers

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
  def handle_info({:updated, _keyword} = _message, socket), do: {:noreply, assign_keywords(socket)}

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Keywords")
    |> assign_keywords()
  end

  defp assign_keywords(socket) do
    assign(
      socket,
      :keywords,
      socket
      |> LiveHelpers.get_current_user_from_socket()
      |> list_keywords()
    )
  end

  defp list_keywords(%User{} = user), do: Keywords.list_keywords(user)
end
