defmodule ElixirInternalCertificationWeb.KeywordLive.Show do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertificationWeb.LiveHelpers

  @impl true
  def mount(_params, session, socket) do
    socket = LiveHelpers.set_current_user_to_socket(socket, session)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _session, socket) do
    user = LiveHelpers.get_current_user_from_socket(socket)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:keyword, Keywords.get_keyword!(user, id))}
  end

  defp page_title(:show), do: "Show Keyword"
end
