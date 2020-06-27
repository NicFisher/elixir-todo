defmodule TodoWeb.TaskController do
  import Phoenix.LiveView.Controller
  use TodoWeb, :controller

  def index(conn, _params) do
    IO.puts "conn"
    IO.inspect conn
    live_render(conn, TodoWeb.TaskLive)
  end
end
