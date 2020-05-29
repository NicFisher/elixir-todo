defmodule TodoWeb.PageController do
  use TodoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def protected(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "protected.html", current_user: user)
  end
end
