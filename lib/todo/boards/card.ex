defmodule Todo.Boards.Card do
  alias Todo.{Accounts.User, Boards.BoardList}
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "cards" do
    field :name, :string, null: false
    field :description, :string
    field :archived, :boolean, default: false
    field :due_date, :date

    belongs_to :board, Board, foreign_key: :board_id, type: :binary_id

    belongs_to :board_list, BoardList, foreign_key: :board_list_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:name, :description, :archived, :due_date, :board_id])
    |> validate_required([:name, :board_id])
  end
end
