# defmodule Todo.ShareTokens.ShareToken do
#   alias Todo.Boards.Board
#   alias Todo.Accounts.User
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   schema "share_token" do
#     field :token, :string, null: false
#     field :expiry_date, :utc_datetime
#     field :used, :boolean, default: false

#     has_one :user, User, foreign_key: :user_id, type: :binary_id
#     has_one :board, Board, foreign_key: :board_id, type: :binary_id

#     timestamps()
#   end

#   @doc false
#   def changeset(card, attrs) do
#     card
#     |> cast(attrs, [:token, :expiry_date, :used])
#     |> validate_required([:token, :expiry_date])
#   end
# end
