defmodule Todo.Boards.Board do
  alias Todo.{Accounts.User, Boards.List}
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "boards" do
    field :name, :string, null: false
    field :archived, :boolean, default: false

    belongs_to :user, User, foreign_key: :user_id, type: :binary_id
    has_many :lists, List
    has_many :board_users, Todo.Boards.BoardUser
    has_many :shared_users, through: [:board_users, :board]
    # many_to_many :shared_board_users, User, join_through: "shared_board_users"

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :archived])
    |> cast_assoc(:shared_users)
    |> validate_required([:name])
  end
end
