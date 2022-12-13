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
  # credo:disable-for-next-line Credo.Check.Refactor.ABCSize
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :keyword, fn %{path: path}, _entry ->
        case Keywords.parse_csv!(path) do
          {:ok, keywords} ->
            current_user = LiveHelpers.get_current_user_from_socket(socket)
            Keywords.create_keywords(current_user, keywords)
            {:ok, path}

          {:error, reason} ->
            {:postpone, {:error, reason}}
        end
      end)

    errors =
      uploaded_files
      |> Enum.filter(&has_error?/1)
      |> Enum.map(fn {:error, reason} -> error_to_string(reason) end)

    if errors == [] do
      {:noreply,
       socket
       |> update(:uploaded_files, &(&1 ++ uploaded_files))
       |> redirect(to: Routes.keyword_path(ElixirInternalCertificationWeb.Endpoint, :index))}
    else
      socket = put_flash(socket, :error, Enum.join(errors, ", "))
      {:noreply, socket}
    end
  end

  defp has_error?({:error, _}), do: true
  defp has_error?(_), do: false

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_keywords), do: "Your file contained too many keywords"
end
