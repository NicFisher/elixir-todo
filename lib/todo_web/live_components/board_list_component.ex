defmodule TodoWeb.BoardListComponent do
  use Phoenix.LiveComponent
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(TodoWeb.BoardListView, "board_list_component.html", assigns)
  end

  def handle_event("display-new-list-modal", %{"id" => id}, socket) do
    send_update TodoWeb.NewCardComponent, id: "new-card-modal", state: "display"
    {:noreply, socket}
  end
end
