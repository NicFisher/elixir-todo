defmodule Todo.Repo.Migrations.AddLists do
  use Ecto.Migration

  def change do
    create table(:lists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :archived, :boolean, default: false
      add :position, :integer, null: false
      add :board_id, references(:boards, type: :uuid), null: false

      timestamps()
    end

    create constraint("lists", :position_must_be_positive, check: "position > 0")

    create unique_index(:lists, [:board_id, :position],
             name: :list_position_and_board_id_unique_index
           )

    create index(:lists, :board_id)
  end
end
