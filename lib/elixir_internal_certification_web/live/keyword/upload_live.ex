defmodule ElixirInternalCertificationWeb.UploadLive do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertificationWeb.LiveHelpers

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket = LiveHelpers.set_current_user_to_socket(socket, session)

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:keyword, accept: ~w(.csv), max_entries: 1, auto_upload: true)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket), do: {:noreply, socket}

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket),
    do: {:noreply, cancel_upload(socket, :keyword, ref)}

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :keyword, fn %{path: path}, _entry ->
        Keywords.parse_csv!(path, fn line_of_keywords ->
          current_user = LiveHelpers.get_current_user_from_socket(socket)
          keyword = List.first(line_of_keywords)
          Keywords.save_keyword_to_database(current_user, keyword)
        end)

        {:ok, path}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
