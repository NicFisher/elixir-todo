defmodule TodoWeb.CardComponent do
  use Phoenix.LiveComponent
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(TodoWeb.CardView, "card_component.html", assigns)
  end
end
