defmodule Todo.Repo.Migrations.CreateResetPasswordToken do
  use Ecto.Migration

  def change do
    create table(:reset_password_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :uuid), null: false
      add :token, :string, null: false
      add :expiry_date, :utc_datetime, null: false
      add :used, :boolean, null: false, default: false

      timestamps()
    end

    create unique_index(:reset_password_tokens, [:token])
  end
end
