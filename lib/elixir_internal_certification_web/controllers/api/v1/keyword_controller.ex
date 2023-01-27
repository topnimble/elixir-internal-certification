defmodule ElixirInternalCertificationWeb.Api.V1.KeywordController do
  use ElixirInternalCertificationWeb, :controller

  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertificationWeb.Api.ErrorView
  alias ElixirInternalCertificationWeb.Helpers.KeywordHelper
  alias Plug.Upload

  @max_keywords_per_upload Application.compile_env!(
                             :elixir_internal_certification,
                             :max_keywords_per_upload
                           )

  def index(%{assigns: %{current_user: current_user}} = conn, _params) do
    keywords = Keywords.list_keywords(current_user)

    conn
    |> put_status(:ok)
    |> render("index.json", %{data: keywords})
  end

  def show(%{assigns: %{current_user: current_user}} = conn, %{"id" => id} = _params) do
    keyword = Keywords.get_keyword!(current_user, id)

    conn
    |> put_status(:ok)
    |> render("show.json", %{data: keyword})
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> put_view(ErrorView)
      |> render("error.json", %{
        code: :not_found,
        detail: dgettext("errors", "Not found")
      })
  end

  def create(
        %{assigns: %{current_user: current_user}} = conn,
        %{"file" => %Upload{path: path}} = _params
      ) do
    case KeywordHelper.process_upload(current_user, path) do
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
