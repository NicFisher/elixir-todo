defmodule Todo.Workers.ShareBoardEmailWorker do

  def new(token) do
    %{"type" => to_string(__MODULE__), "token" => token}
  end

  def enqueue(token) do
    new(token)
    |> Todo.JobQueue.new()
    |> Todo.Repo.insert()
  end
end
