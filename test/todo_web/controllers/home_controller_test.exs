defmodule TodoWeb.HomeControllerTest do
  use TodoWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn) == "/login"
  end
end
