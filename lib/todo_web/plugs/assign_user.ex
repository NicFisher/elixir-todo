defmodule TodoWeb.Plugs.AssignUser do
  import Plug.Conn

  def init(_params), do: nil

  def call(conn, _params) do
    assign(conn, :current_user, Guardian.Plug.current_resource(conn))
  end
end
