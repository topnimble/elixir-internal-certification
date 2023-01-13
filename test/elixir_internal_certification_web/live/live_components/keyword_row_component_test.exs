defmodule ElixirInternalCertificationWeb.LiveComponents.KeywordRowComponentTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest

  alias ElixirInternalCertificationWeb.LiveComponents.KeywordRowComponent

  describe "render/1" do
    test "given a keyword, returns a keyword row" do
      keyword = insert(:keyword, status: :new)

      assert render_component(&KeywordRowComponent.render/1, keyword: keyword) ==
               ~s(<tr id="keyword-#{keyword.id}">
  <td class="align-middle">#{keyword.title}</td>
  <td class="align-middle"><span class="badge rounded-pill bg-secondary">New</span></td>
  <td class="align-middle text-end"><div class="spinner-border spinner-border-sm" role="status">
  <span class="visually-hidden">Processing...</span>
</div></td>
</tr>)
    end
  end
end
