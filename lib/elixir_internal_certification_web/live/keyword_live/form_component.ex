defmodule ElixirInternalCertificationWeb.KeywordLive.FormComponent do
  use ElixirInternalCertificationWeb, :live_component

  alias ElixirInternalCertification.Keywords

  @impl true
  def update(%{keyword: keyword} = assigns, socket) do
    changeset = Keywords.change_keyword(keyword)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"keyword" => keyword_params}, socket) do
    changeset =
      socket.assigns.keyword
      |> Keywords.change_keyword(keyword_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"keyword" => keyword_params}, socket) do
    save_keyword(socket, socket.assigns.action, keyword_params)
  end

  defp save_keyword(socket, :edit, keyword_params) do
    case Keywords.update_keyword(socket.assigns.keyword, keyword_params) do
      {:ok, _keyword} ->
        {:noreply,
         socket
         |> put_flash(:info, "Keyword updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_keyword(socket, :new, keyword_params) do
    case Keywords.create_keyword(keyword_params) do
      {:ok, _keyword} ->
        {:noreply,
         socket
         |> put_flash(:info, "Keyword created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
