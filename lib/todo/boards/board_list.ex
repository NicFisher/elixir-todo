defmodule Todo.Boards.BoardList do
  alias Todo.Boards.Board
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "board_lists" do
    field :name, :string, null: false
    field :archived, :boolean, default: false
    field :position, :integer, null: false

    belongs_to :board, Board, foreign_key: :board_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :archived, :position])
    |> validate_number(:position, greater_than: 0)
    |> validate_required([:name, :position])
  end
end
