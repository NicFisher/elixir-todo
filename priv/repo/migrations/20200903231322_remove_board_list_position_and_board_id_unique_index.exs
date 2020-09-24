defmodule Todo.Repo.Migrations.RemoveBoardListPositionAndBoardIdUniqueIndex do
  use Ecto.Migration

  def up do
    drop index(:board_list, [:position_and_board_id_unique])

    create index(:board_lists, [:board_id, :position],
             name: :board_list_board_id_and_position_index
           )
  end

  def down do
    drop index(:board_list, [:board_id_and_position])

    create unique_index(:board_lists, [:board_id, :position],
             name: :board_list_position_and_board_id_unique_index
           )
  end
end
