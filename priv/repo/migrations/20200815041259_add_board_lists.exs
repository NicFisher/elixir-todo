defmodule Todo.Repo.Migrations.AddBoardLists do
  use Ecto.Migration

  def change do
    create table(:board_lists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :archived, :boolean, default: false
      add :position, :integer, null: false
      add :board_id, references(:boards, type: :uuid), null: false

      timestamps()
    end
  end
end
