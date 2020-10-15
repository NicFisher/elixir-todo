defmodule Todo.Repo.Migrations.AddBoardListPositionAndBoardIdUniqueIndex do
  use Ecto.Migration

  def up do
    drop index(:list, [:board_id_and_position])

    execute "ALTER TABLE lists ADD CONSTRAINT unique_list_position_and_board_id UNIQUE (board_id, position) DEFERRABLE INITIALLY DEFERRED;"
  end

  def down do
    execute "ALTER TABLE lists DROP CONSTRAINT unique_list_position_and_board_id;"

    create index(:lists, [:board_id, :position], name: :list_board_id_and_position_index)
  end
end
