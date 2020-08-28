defmodule Todo.Boards.Board do
  alias Todo.{Accounts.User, Boards.BoardList}
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "boards" do
    field :name, :string, null: false
    field :archived, :boolean, default: false

    belongs_to :user, User, foreign_key: :user_id, type: :binary_id
    has_many :board_lists, BoardList

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :archived])
    |> validate_required([:name])
  end
end
