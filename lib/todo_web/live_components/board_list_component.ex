defmodule BoardListComponent do
  use Phoenix.LiveComponent
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(TodoWeb.BoardListView, "board_list_component.html", assigns)
  end
end
