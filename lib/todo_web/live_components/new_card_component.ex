defmodule TodoWeb.NewCardComponent do
  use Phoenix.LiveComponent
  use Phoenix.LiveView
  alias Todo.Boards
  alias Todo.Boards.{Card, BoardList}

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "new_card_component.html", assigns)
  end

  def mount(socket) do
    {:ok,
     assign(socket, modal_state: "hidden", error: false, changeset: Boards.change_card(%Card{}))}
  end

  def update(%{id: "new-card-component", modal_state: modal_state}, socket) do
    {:ok, assign(socket, :modal_state, modal_state)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("hide-new-board-list-component", params, socket) do
    {:noreply, assign(socket, modal_state: "hidden", error: false)}
  end

  def handle_event("create", %{"card" => attrs}, %{assigns: %{board_list: board_list}} = socket) do
    with {:ok, card} <-
           Todo.Boards.create_card(Map.put(attrs, "board_id", board_list.board_id), board_list) do
      send(self(), {:card_created})
      {:noreply, assign(socket, modal_state: "hidden", error: false)}
    else
      error -> {:noreply, assign(socket, :error, true)}
    end
  end
end
