defmodule TodoWeb.BoardLiveView do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(TodoWeb.BoardView, "show.html", assigns)
    # ~L"""
    # Current temperature: <%= @temperature %>
    # """
  end

  def mount(%{"id" => id}, %{"guardian_default_token" => token}, socket) do
    # require IEx; IEx.pry
    {:ok, claims} = Todo.Accounts.Guardian.decode_and_verify(token)
    {:ok, user} = Todo.Accounts.Guardian.resource_from_claims(claims)

    # current_resource()
    # changeset = Boards.change_board(get_board(conn, id))
    board = Todo.Boards.get_board!(id, user.id)
    changeset = Todo.Boards.change_board(board)

    # Phoenix.View.render(conn, "show.html", board: get_board(conn, id), changeset: changeset)
    # temperature = Thermostat.get_user_reading(user_id)
    {:ok, assign(socket, board: board, changeset: changeset)}
  end
end
