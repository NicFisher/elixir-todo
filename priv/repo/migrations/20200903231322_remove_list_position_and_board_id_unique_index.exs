defmodule Todo.Repo.Migrations.RemoveListPositionAndBoardIdUniqueIndex do
  use Ecto.Migration

  def up do
    drop index(:list, [:position_and_board_id_unique])

    create index(:lists, [:board_id, :position], name: :list_board_id_and_position_index)
  end

  def down do
    drop index(:list, [:board_id_and_position])

    create unique_index(:lists, [:board_id, :position],
             name: :list_position_and_board_id_unique_index
           )
  end
end
