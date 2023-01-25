defmodule ElixirInternalCertificationWeb.SetCurrentUserPlugTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import ElixirInternalCertificationWeb.Gettext

  alias ElixirInternalCertificationWeb.SetCurrentUserPlug

  describe "init/1" do
    test "given options, returns options" do
      assert SetCurrentUserPlug.init([]) == []
    end
  end

  describe "call/2" do
    test "given Guardian resource, does NOT halt the conn and assigns the current user to the conn" do
      user = insert(:user)

      conn =
        build_conn()
        |> Plug.Conn.put_private(:guardian_default_resource, user)
        |> SetCurrentUserPlug.call([])

      assert conn.halted == false
      assert conn.assigns == %{current_user: user}
    end

    test "given NO Guardian resource, halts the conn and returns 401 error" do
      conn = SetCurrentUserPlug.call(build_conn(), [])

      assert conn.halted == true

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{
                   "code" => "unauthenticated",
                   "detail" => dgettext("errors", "Unauthenticated")
                 }
               ]
             }
    end
  end
end
