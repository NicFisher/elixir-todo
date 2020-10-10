defmodule Todo.Repo.Migrations.AddCardsTable do
  use Ecto.Migration

  def change do
    create table(:cards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :archived, :boolean, default: false
      add :due_date, :date
      add :list_id, references(:lists, type: :uuid), null: false

      timestamps()
    end

    create index("cards", [:list_id],
             where: "archived = false",
             name: :cards_list_id_and_non_archived_index
           )

    create index(:cards, :list_id)
    create index(:cards, :id)
  end
end
