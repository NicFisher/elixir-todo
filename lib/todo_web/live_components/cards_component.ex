defmodule TodoWeb.CardsComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "cards_component.html", assigns)
  end

  def handle_event("display-edit-card-component", %{"id" => id, "card-id" => card_id}, socket) do
    card = Enum.find(socket.assigns.cards, fn %{id: id} -> id == card_id end)
    send_update(TodoWeb.EditCardComponent, id: id, card: card, modal_state: "display")
    {:noreply, socket}
  end
end
