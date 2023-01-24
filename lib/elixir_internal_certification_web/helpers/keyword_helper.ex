defmodule ElixirInternalCertificationWeb.Helpers.KeywordHelper do
  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.{KeywordLookups, Keywords}

  def process_upload(%User{} = current_user, path) do
    with {:ok, keywords} <- Keywords.parse_csv!(path),
         {:ok, {_, records}} <- Keywords.create_keywords(current_user, keywords),
         scheduled_keyword_lookups <- Enum.map(records, &KeywordLookups.schedule_keyword_lookup/1) do
      {:ok, {path, records, scheduled_keyword_lookups}}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
