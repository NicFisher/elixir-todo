defmodule TodoWeb.NewCardComponent do
  use Phoenix.LiveComponent
  use Phoenix.LiveView
  alias Todo.Boards
  alias Todo.Boards.{Card, BoardList}

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "new_card_modal.html", assigns)
  end

  def mount(socket) do
    {:ok, assign(socket, modal_state: "hidden", changeset: Boards.change_card(%Card{}))}
  end

  def update(%{id: "new-card-modal", modal_state: modal_state}, socket) do
    {:ok, assign(socket, :modal_state, modal_state)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("hide-new-list-modal", params, socket) do
    {:noreply, assign(socket, :modal_state, "hidden")}
  end

  def handle_event("create", %{"card" => %{"description" => description, "name" => name}}, %{assigns: %{board_list: board_list} } = socket) do
    {:ok, card} = Todo.Boards.create_card(%{"description" => description, "name" => name, "board_id" => board_list.board_id}, board_list)

    send self(), {:card_created, card}
    {:noreply, assign(socket, :modal_state, "hidden")}
  end
end
