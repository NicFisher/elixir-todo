defmodule Todo.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset
  # alias Todo.Accounts.User

  schema "tasks" do
    field :description, :string
    # field :user_id, :
    # belongs_to :user, User
    belongs_to :user, Todo.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    # require IEx; IEx.pry;
    task
    |> cast(attrs, [:description, :user_id])
    |> validate_required([:description, :user_id])
    |> unique_constraint(:user_id)
  end
end
