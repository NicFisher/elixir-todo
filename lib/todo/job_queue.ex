defmodule Todo.JobQueue do
  use EctoJob.JobQueue, table_name: "jobs"

  def perform(multi, %{"type" => type} = params) do
    type
    |> String.to_existing_atom()
    |> :erlang.apply(:perform, [multi, params])
  end
end
