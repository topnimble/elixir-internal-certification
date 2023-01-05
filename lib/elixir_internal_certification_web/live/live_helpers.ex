defmodule ElixirInternalCertificationWeb.LiveHelpers do
  use Phoenix.Component

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertificationWeb.Endpoint
  alias ElixirInternalCertificationWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView.Socket

  def set_current_user_to_socket(%Socket{} = socket, %{"user_token" => user_token} = _session) do
    user = Accounts.get_user_by_session_token(user_token)
    assign_new(socket, :current_user, fn -> user end)
  end

  def get_current_user_from_socket(
        %Socket{assigns: %{current_user: %User{} = current_user}} = _socket
      ),
      do: current_user

  def show_button(%{keyword: %Keyword{status: keyword_status}} = assigns)
      when keyword_status in [:new, :pending],
      do: ~H"""
      <div class="spinner-border spinner-border-sm" role="status">
        <span class="visually-hidden">Processing...</span>
      </div>
      """

  def show_button(%{keyword: %Keyword{id: keyword_id, status: keyword_status}} = assigns)
      when keyword_status == :completed,
      do: ~H"""
      <%= live_redirect("Show", to: Routes.keyword_show_path(Endpoint, :show, keyword_id)) %>
      """

  def show_button(assigns), do: ~H()

  def status_badge(%{keyword: %Keyword{status: keyword_status}} = assigns)
      when keyword_status == :new,
      do: ~H"""
      <span class="badge rounded-pill bg-secondary">New</span>
      """

  def status_badge(%{keyword: %Keyword{status: keyword_status}} = assigns)
      when keyword_status == :pending,
      do: ~H"""
      <span class="badge rounded-pill bg-info">Pending</span>
      """

  def status_badge(%{keyword: %Keyword{status: keyword_status}} = assigns)
      when keyword_status == :completed,
      do: ~H"""
      <span class="badge rounded-pill bg-success">Completed</span>
      """

  def status_badge(%{keyword: %Keyword{status: keyword_status}} = assigns)
      when keyword_status == :failed,
      do: ~H"""
      <span class="badge rounded-pill bg-danger">Failed</span>
      """
end
