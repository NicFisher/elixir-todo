defmodule Todo.Repo.Migrations.RemoveBoardListPositionAndBoardIdUniqueIndex do
  use Ecto.Migration

  def change do
    drop index(:board_list, [:position_and_board_id_unique])
  end
end
