defmodule TodoWeb.CardsComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "cards_component.html", assigns)
  end
end
