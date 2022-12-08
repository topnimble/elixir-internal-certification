defmodule ElixirInternalCertificationWeb.KeywordLive do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertificationWeb.LiveHelpers

  @impl true
  def mount(_params, session, socket) do
    socket = LiveHelpers.set_current_user_to_socket(socket, session)

    {:ok,
     assign(
       socket,
       :keywords,
       socket
       |> LiveHelpers.get_current_user_from_socket()
       |> list_keywords()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Keywords")
    |> assign(:keyword, nil)
  end

  defp list_keywords(%User{} = user), do: Keywords.list_keywords(user)
end
