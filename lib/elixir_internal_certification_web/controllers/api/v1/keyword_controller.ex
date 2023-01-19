defmodule ElixirInternalCertificationWeb.Api.V1.KeywordController do
  use ElixirInternalCertificationWeb, :controller

  alias ElixirInternalCertification.Keyword.{KeywordLookups, Keywords}
  alias ElixirInternalCertificationWeb.Api.ErrorView
  alias Plug.Upload

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
          detail: reason
        })
    end
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
end
