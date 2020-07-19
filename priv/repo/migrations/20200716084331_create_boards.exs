defmodule Todo.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :archived, :boolean, default: false
      add :user_id, references(:users, type: :uuid), null: false

      timestamps()
    end
  end
end
