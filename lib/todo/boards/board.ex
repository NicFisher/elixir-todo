defmodule Todo.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "boards" do
    field :name, :string
    field :archived, :boolean

    belongs_to :user, Todo.Accounts.User, foreign_key: :user_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :archived])
    |> validate_required([:name])
  end
end
