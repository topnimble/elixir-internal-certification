defmodule ElixirInternalCertificationWeb.LiveComponents.KeywordRowComponentTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest

  alias ElixirInternalCertificationWeb.LiveComponents.KeywordRowComponent

  describe "render/1" do
    test "given a keyword with `new` status, returns a keyword row" do
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

    test "given a keyword with `pending` status, returns a keyword row" do
      keyword = insert(:keyword, status: :pending)

      assert render_component(&KeywordRowComponent.render/1, keyword: keyword) ==
               ~s(<tr id="keyword-#{keyword.id}">
  <td class="align-middle">#{keyword.title}</td>
  <td class="align-middle"><span class="badge rounded-pill bg-info">Pending</span></td>
  <td class="align-middle text-end"><div class="spinner-border spinner-border-sm" role="status">
  <span class="visually-hidden">Processing...</span>
</div></td>
</tr>)
    end

    test "given a keyword with `completed` status, returns a keyword row" do
      keyword = insert(:keyword, status: :completed)
      _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      assert render_component(&KeywordRowComponent.render/1, keyword: keyword) ==
               ~s(<tr id="keyword-#{keyword.id}">
  <td class="align-middle">#{keyword.title}</td>
  <td class="align-middle"><span class="badge rounded-pill bg-success">Completed</span></td>
  <td class="align-middle text-end"><a data-phx-link="redirect" data-phx-link-state="push" href="/keywords/#{keyword.id}">Show</a></td>
</tr>)
    end

    test "given a keyword with `failed` status, returns a keyword row" do
      keyword = insert(:keyword, status: :failed)

      assert render_component(&KeywordRowComponent.render/1, keyword: keyword) ==
               ~s(<tr id="keyword-#{keyword.id}">
  <td class="align-middle">#{keyword.title}</td>
  <td class="align-middle"><span class="badge rounded-pill bg-danger">Failed</span></td>
  <td class="align-middle text-end"></td>
</tr>)
    end
  end
end
