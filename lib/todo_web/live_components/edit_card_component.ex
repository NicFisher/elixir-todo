defmodule TodoWeb.EditCardComponent do
  use Phoenix.LiveComponent
  alias Todo.Boards
  alias Todo.Boards.Card

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "edit_card_component.html", assigns)
  end

  def mount(socket) do
    {:ok,
     assign(socket, modal_state: "hidden", error: false, changeset: Boards.change_card(%Card{}))}
  end

  def update(%{id: "edit-card-component", modal_state: modal_state, card: card}, socket) do
    {:ok, assign(socket, modal_state: modal_state, changeset: Boards.change_card(card))}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("hide-edit-card-component", _params, socket) do
    {:noreply, assign(socket, modal_state: "hidden", error: false)}
  end

  def handle_event("update", %{"card" => attrs}, %{assigns: %{list: list}} = socket) do
    with {:ok, _card} <-
           Todo.Boards.create_card(Map.put(attrs, "board_id", list.board_id), list) do
      send(self(), {:card_updated})
      {:noreply, assign(socket, modal_state: "hidden", error: false)}
    else
      _error -> {:noreply, assign(socket, :error, true)}
    end
  end
end
