defmodule Todo.Repo.Migrations.AddBoardUsers do
  use Ecto.Migration

  def change do
    create table(:board_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :board_id, references(:boards, type: :uuid), null: false
      add :user_id, references(:users, type: :uuid), null: false

      timestamps()
    end

    create unique_index(:board_users, [:board_id, :user_id])
  end
end
