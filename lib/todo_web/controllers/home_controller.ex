defmodule TodoWeb.HomeController do
  use TodoWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/login")
  end
end
