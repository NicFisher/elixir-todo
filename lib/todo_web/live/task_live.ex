defmodule TodoWeb.TaskLive do
  use Phoenix.LiveView

  # get all tasks for the user
  # allow tasks to be created, deleted and updated
  # when a task is updated, it should change the task list

  def render(assigns) do
    Phoenix.View.render(TodoWeb.TaskView, "index.html", assigns)
  end

  def handle_event("update_status", _value, socket) do
    {:noreply, assign(socket, status: "Done")}
  end

  def mount(_params, assigns, socket) do
    IO.inspect(assigns)
    {:ok, assign(socket, :status, "Ready!")}
  end
end
