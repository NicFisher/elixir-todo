defmodule TodoWeb.ListComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(TodoWeb.ListView, "list_component.html", assigns)
  end

  def handle_event("display-new-card-component", %{"id" => id}, socket) do
    send_update(TodoWeb.NewCardComponent, id: id, modal_state: "display")
    {:noreply, socket}
  end
end
