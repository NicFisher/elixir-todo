defmodule Todo.Repo.Migrations.AddBoardUsers do
  use Ecto.Migration

  def change do
    create table(:board_users) do
      add :board_id, references(:boards, type: :uuid), null: false
      add :user_id, references(:users, type: :uuid), null: false
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:board_users, [:board_id, :user_id, :active])
  end
end
