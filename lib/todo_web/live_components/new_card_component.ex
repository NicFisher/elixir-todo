defmodule TodoWeb.NewCardComponent do
  use Phoenix.LiveComponent
  alias Todo.Boards
  alias Todo.Boards.Card

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

  def handle_event("hide-new-list-component", _params, socket) do
    {:noreply, assign(socket, modal_state: "hidden", error: false)}
  end

  def handle_event("create", %{"card" => attrs}, %{assigns: %{list: list}} = socket) do
    with {:ok, _card} <-
           Todo.Boards.create_card(Map.put(attrs, "board_id", list.board_id), list) do
      send(self(), {:card_created})
      {:noreply, assign(socket, modal_state: "hidden", error: false)}
    else
      _error -> {:noreply, assign(socket, :error, true)}
    end
  end
end
