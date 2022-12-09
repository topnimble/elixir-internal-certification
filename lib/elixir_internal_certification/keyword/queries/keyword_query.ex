defmodule ElixirInternalCertification.Keyword.Queries.KeywordQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  def list_keywords_by_user(%User{id: user_id} = _user) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> order_by([k], desc: k.id)
  end
end
