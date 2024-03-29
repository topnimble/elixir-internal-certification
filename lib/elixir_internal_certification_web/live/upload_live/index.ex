defmodule ElixirInternalCertificationWeb.UploadLive.Index do
  use ElixirInternalCertificationWeb, :live_view

  alias ElixirInternalCertificationWeb.Helpers.KeywordHelper
  alias ElixirInternalCertificationWeb.LiveHelpers

  @max_keywords_per_upload Application.compile_env!(
                             :elixir_internal_certification,
                             :max_keywords_per_upload
                           )

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
    uploaded_files = handle_file_uploading(socket)
    errors = extract_errors(uploaded_files)
    file_uploading_response(socket, uploaded_files, errors)
  end

  defp handle_file_uploading(socket) do
    current_user = LiveHelpers.get_current_user_from_socket(socket)

    consume_uploaded_entries(socket, :keyword, fn %{path: path}, _entry ->
      case KeywordHelper.process_upload(current_user, path) do
        {:ok, results} -> {:ok, results}
        {:error, reason} -> {:postpone, {:error, reason}}
      end
    end)
  end

  defp extract_errors(uploaded_files) do
    uploaded_files
    |> Enum.filter(&has_error?/1)
    |> Enum.map(fn {:error, reason} -> error_to_string(reason) end)
  end

  defp file_uploading_response(socket, uploaded_files, errors) do
    if errors == [] do
      {:noreply,
       socket
       |> update(:uploaded_files, &(&1 ++ uploaded_files))
       |> redirect(to: Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))}
    else
      {:noreply, put_flash(socket, :error, Enum.join(errors, ", "))}
    end
  end

  defp max_keywords_per_upload, do: @max_keywords_per_upload

  defp has_error?({:error, _}), do: true
  defp has_error?(_), do: false

  defp error_to_string(:too_large), do: dgettext("errors", "Too large")
  defp error_to_string(:too_many_files), do: dgettext("errors", "You have selected too many files")

  defp error_to_string(:not_accepted),
    do: dgettext("errors", "You have selected an unacceptable file type")

  defp error_to_string(:too_many_keywords),
    do:
      dgettext(
        "errors",
        "You have selected file with more than %{max_keywords_per_upload} keywords",
        max_keywords_per_upload: @max_keywords_per_upload
      )

  defp error_to_string(:invalid_data),
    do: dgettext("errors", "You have selected file with invalid data")
end
