defmodule TodoWeb.NewCardComponent do
  use Phoenix.LiveComponent
  use Phoenix.LiveView
  alias Todo.Boards
  alias Todo.Boards.Card

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "new_card_modal.html", assigns)
  end

  def mount(socket) do
    {:ok, assign(socket, modal_state: "hidden", changeset: Boards.change_card(%Card{}))}
  end

  def update(%{id: "new-card-modal", state: state}, socket) do
    {:ok, assign(socket, :modal_state, state)}
  end

  def update(assigns, socket) do
    {:ok, socket}
  end

  def handle_event("hide-new-list-modal", params, socket) do
    {:noreply, assign(socket, :modal_state, "hidden")}
  end
end
