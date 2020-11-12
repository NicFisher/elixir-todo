defmodule Todo.Boards.BoardUser do
  alias Todo.{Accounts.User, Boards.Board}
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "board_users" do
    field :active, :boolean, default: true
    belongs_to :user, User, foreign_key: :user_id, type: :binary_id
    belongs_to :board, Board, foreign_key: :board_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(board_user, attrs) do
    board_user
    |> cast(attrs, [:user_id, :board_id])
    # |> foreign_key_constraint(:user_id)
    # |> foreign_key_constraint(:board_id)
    |> validate_required([:user_id, :board_id])

  #   |> unique_constraint([:user, :project],
  #   name: :user_id_project_id_unique_index,
  #   message: @already_exists
  # )
  end
end
