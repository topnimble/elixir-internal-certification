defmodule ElixirInternalCertificationWeb.LiveHelpers do
  use Phoenix.Component

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertification.Account.Schemas.User
  alias Phoenix.LiveView.Socket

  def set_current_user_to_socket(%Socket{} = socket, %{"user_token" => user_token} = _session) do
    user = Accounts.get_user_by_session_token(user_token)
    assign_new(socket, :current_user, fn -> user end)
  end

  def get_current_user_from_socket(%Socket{assigns: %{current_user: %User{} = current_user}} = _socket), do: current_user
end
