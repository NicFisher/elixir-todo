defmodule Todo.Repo.Migrations.UpdateUserFieldsToNotNull do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :email, :string, null: false
      modify :password, :string, null: false
      modify :name, :string, null: false
    end
  end

  def down do
    alter table(:users) do
      modify :email, :string, null: true
      modify :password, :string, null: true
      modify :name, :string, null: true
    end
  end
end
