defmodule Todo.Boards.ShareBoardToken do
  alias Todo.Boards.Board
  alias Todo.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "share_board_tokens" do
    field :token, :string, null: false
    field :expiry_date, :utc_datetime, null: false

    belongs_to :user, User, foreign_key: :user_id, type: :binary_id
    belongs_to :board, Board, foreign_key: :board_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(share_board_token, attrs) do
    share_board_token
    |> cast(attrs, [:user_id, :board_id, :token, :expiry_date])
    |> validate_required([:user_id, :board_id, :token, :expiry_date])
    |> assoc_constraint(:user)
    |> assoc_constraint(:board)
  end
end
