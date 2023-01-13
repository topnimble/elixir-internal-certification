defmodule ElixirInternalCertificationWeb.LiveComponents.KeywordRowComponent do
  use Phoenix.LiveComponent

  alias ElixirInternalCertificationWeb.LiveHelpers

  def render(assigns) do
    ~H"""
    <tr id={"keyword-#{@keyword.id}"}>
      <td class="align-middle"><%= @keyword.title %></td>
      <td class="align-middle"><LiveHelpers.status_badge keyword={@keyword} /></td>
      <td class="align-middle text-end"><LiveHelpers.show_button keyword={@keyword} /></td>
    </tr>
    """
  end
end
