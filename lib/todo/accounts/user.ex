defmodule Todo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Argon2

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :password, :string, null: false
    field :email, :string, null: false
    field :name, :string, null: false
    has_many :boards, Todo.Boards.Board
    has_many :board_users, Todo.Boards.BoardUser
    has_many :shared_boards, through: [:board_users, :board]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name])
    |> validate_required([:email, :password, :name])
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
