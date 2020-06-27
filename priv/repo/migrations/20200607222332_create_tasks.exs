defmodule Todo.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :description, :string
      add :user_id, references(:users, type: :uuid), null: false

      timestamps()
    end
  end
end
