defmodule ElixirInternalCertification.Keyword.Queries.KeywordQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertification.Account.Schemas.User

  def list_keywords(%User{id: user_id} = _user) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> order_by([k], desc: k.inserted_at)
  end
end
