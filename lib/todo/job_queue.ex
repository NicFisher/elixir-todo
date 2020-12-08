defmodule Todo.JobQueue do
  use EctoJob.JobQueue, table_name: "jobs"

  def perform(multi, %{"type" => "Elixir.Todo.Workers.ShareBoardEmailWorker", "token" => token}) do
    IO.puts("Token is here #{token}")
    multi
    |> Todo.Repo.transaction()
  end
end
