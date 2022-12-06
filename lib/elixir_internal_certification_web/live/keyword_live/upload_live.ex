defmodule ElixirInternalCertificationWeb.UploadLive do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Account.Accounts

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    socket = assign_new(socket, :current_user, fn -> user end)

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:keyword, accept: ~w(.csv), max_entries: 1, auto_upload: true)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :keyword, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :keyword, fn %{path: path}, _entry ->
        Keywords.parse_csv!(path, fn line_of_keywords ->
          keyword = List.first(line_of_keywords)
          Keywords.save_keyword_to_database(socket.assigns.current_user, keyword)
        end)

        {:ok, path}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
