defmodule ElixirInternalCertificationWeb.ReadinessRequestTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  test "returns 200", %{conn: conn} do
    conn =
      get(
        conn,
        "#{Application.get_env(:elixir_internal_certification, ElixirInternalCertificationWeb.Endpoint)[:health_path]}/readiness"
      )

    assert response(conn, :ok) =~ "ready"
  end
end
