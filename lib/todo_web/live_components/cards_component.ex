defmodule TodoWeb.CardsComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "cards_component.html", assigns)
  end

  def handle_event(
        "display-edit-card-component",
        %{"id" => id, "card-id" => card_id},
        %{assigns: %{cards: cards}} = socket
      ) do
    send_update(TodoWeb.EditCardComponent,
      id: id,
      card: find_card(cards, card_id),
      modal_state: "display",
      action: "display-edit-card-component"
    )

    {:noreply, socket}
  end

  def handle_event(
        "display-archive-card-component",
        %{"id" => id, "card-id" => card_id},
        %{assigns: %{cards: cards}} = socket
      ) do
    send_update(TodoWeb.ArchiveCardComponent,
      id: id,
      card: find_card(cards, card_id),
      modal_state: "display",
      action: "display-archive-card-component"
    )

    {:noreply, socket}
  end

  defp find_card(cards, card_id) do
    Enum.find(cards, fn %{id: id} -> id == card_id end)
  end
end
