defmodule ElixirInternalCertificationWeb.LivenessRequestTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  test "returns 200", %{conn: conn} do
    conn =
      get(
        conn,
        "#{Application.get_env(:elixir_internal_certification, ElixirInternalCertificationWeb.Endpoint)[:health_path]}/liveness"
      )

    assert response(conn, :ok) =~ "alive"
  end
end
