defmodule TodoWeb.EditCardComponent do
  use Phoenix.LiveComponent
  alias Todo.Boards
  alias Todo.Boards.Card

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "edit_card_component.html", assigns)
  end

  def mount(socket) do
    {:ok,
     assign(socket,
       modal_state: "hidden",
       error: false,
       display_due_date: false,
       changeset: Boards.change_card(%Card{})
     )}
  end

  def update(
        %{action: "display-edit-card-component", modal_state: modal_state, card: card},
        socket
      ) do
    {:ok,
     assign(socket,
       modal_state: modal_state,
       changeset: Boards.change_card(card),
       card: card,
       due_date_value: card.due_date
     )}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("hide-edit-card-component", _params, socket) do
    {:noreply, assign(socket, modal_state: "hidden", error: false, display_due_date: false)}
  end

  def handle_event("display-due-date", _params, socket) do
    {:noreply, assign(socket, display_due_date: true)}
  end

  def handle_event("update-form", %{"card" => attrs}, socket) do
    {:noreply, assign(socket, changeset: Boards.change_card(%Card{}, attrs))}
  end

  def handle_event("update", %{"card" => attrs}, socket) do
    with {:ok, _updated_card} <-
           Todo.Boards.update_card(socket.assigns.card, attrs) do
      send(self(), {:refresh_board})
      {:noreply, assign(socket, modal_state: "hidden", error: false, display_due_date: false)}
    else
      _error ->
        {:noreply,
         assign(socket, error: true, changeset: Boards.change_card(socket.assigns.card, attrs))}
    end
  end
end
