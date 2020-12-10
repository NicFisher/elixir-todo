defmodule Todo.Workers.ShareBoardEmailWorker do
  def new(token) do
    %{"type" => to_string(__MODULE__), "token" => token}
  end

  def enqueue(token) do
    new(token)
    |> Todo.JobQueue.new()
    |> Todo.Repo.insert()
  end

  def perform(%Ecto.Multi{} = multi, %{"token" => _token}) do
    IO.puts("Performing Todo.Workers.ShareBoardEmailWorker")

    multi
    |> Todo.Repo.transaction()
  end
end
