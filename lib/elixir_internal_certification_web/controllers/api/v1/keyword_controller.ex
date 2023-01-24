defmodule ElixirInternalCertificationWeb.Api.V1.KeywordController do
  use ElixirInternalCertificationWeb, :controller

  alias ElixirInternalCertification.Keyword.{KeywordLookups, Keywords}
  alias ElixirInternalCertificationWeb.Api.ErrorView
  alias Plug.Upload

  @max_keywords_per_upload Application.compile_env!(
                             :elixir_internal_certification,
                             :max_keywords_per_upload
                           )

  def create(conn, %{"file" => %Upload{path: path} = _uploaded_file} = _params) do
    case process_data(conn, path) do
      {:ok, {_path, records, _scheduled_keyword_lookups}} ->
        conn
        |> put_status(:ok)
        |> render("index.json", %{data: records})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("error.json", %{
          code: :unprocessable_entity,
          detail: error_to_string(reason)
        })
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("error.json", %{
      code: :unprocessable_entity,
      detail: dgettext("errors", "Missing input file argument")
    })
  end

  defp process_data(%{assigns: %{current_user: current_user}} = _conn, path) do
    with {:ok, keywords} <- Keywords.parse_csv!(path),
         {:ok, {_, records}} <- Keywords.create_keywords(current_user, keywords),
         scheduled_keyword_lookups <- Enum.map(records, &KeywordLookups.schedule_keyword_lookup/1) do
      {:ok, {path, records, scheduled_keyword_lookups}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

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
