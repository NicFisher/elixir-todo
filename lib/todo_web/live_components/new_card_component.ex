defmodule TodoWeb.NewCardComponent do
  use Phoenix.LiveComponent
  alias Todo.Boards
  alias Todo.Boards.Card

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "new_card_component.html", assigns)
  end

  def mount(socket) do
    {:ok,
     assign(socket,
       modal_state: "hidden",
       display_due_date: false,
       error: false,
       changeset: Boards.change_card(%Card{})
     )}
  end

  def update(%{id: "new-card-component", modal_state: modal_state}, socket) do
    {:ok, assign(socket, :modal_state, modal_state)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("display-due-date", _params, socket) do
    {:noreply, assign(socket, display_due_date: true)}
  end

  def handle_event("hide-new-card-component", _params, socket) do
    {:noreply, assign(socket, hide_modal_and_reset_state())}
  end

  def handle_event("update-form", %{"card" => attrs}, socket) do
    {:noreply, assign(socket, changeset: Boards.change_card(%Card{}, attrs))}
  end

  def handle_event("create", %{"card" => attrs}, %{assigns: %{list: list}} = socket) do
    with {:ok, _card} <- Boards.create_card(attrs, list) do
      send(self(), {:refresh_board})
      {:noreply, assign(socket, hide_modal_and_reset_state())}
    else
      _error -> {:noreply, assign(socket, :error, true)}
    end
  end

  defp hide_modal_and_reset_state() do
    %{
      modal_state: "hidden",
      error: false,
      display_due_date: false,
      changeset: Boards.change_card(%Card{})
    }
  end
end
