defmodule Todo.Repo.Migrations.AddShareBoardTokenTable do
  use Ecto.Migration

  def change do
    create table(:share_board_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :board_id, references(:boards, type: :uuid), null: false
      add :user_id, references(:users, type: :uuid), null: false
      add :token, :string, null: false
      add :expiry_date, :utc_datetime, null: false

      timestamps()
    end

    create unique_index(:share_board_tokens, [:token])
  end
end
