defmodule ElixirInternalCertificationWeb.KeywordLive.Index do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :keywords, list_keywords())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Keyword")
    |> assign(:keyword, Keywords.get_keyword!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Keyword")
    |> assign(:keyword, %Keyword{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Keywords")
    |> assign(:keyword, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    keyword = Keywords.get_keyword!(id)
    {:ok, _} = Keywords.delete_keyword(keyword)

    {:noreply, assign(socket, :keywords, list_keywords())}
  end

  defp list_keywords do
    Keywords.list_keywords()
  end
end
