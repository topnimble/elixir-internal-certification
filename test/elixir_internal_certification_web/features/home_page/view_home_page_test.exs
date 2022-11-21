defmodule ElixirInternalCertificationWeb.HomePage.ViewHomePageTest do
  use ElixirInternalCertificationWeb.FeatureCase

  feature "view home page", %{session: session} do
    visit(session, Routes.page_path(ElixirInternalCertificationWeb.Endpoint, :index))

    assert_has(session, Query.text("Welcome to Phoenix!"))
  end
end
