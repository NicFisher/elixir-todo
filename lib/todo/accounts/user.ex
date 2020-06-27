defmodule Todo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Argon2

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :password, :string
    field :username, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :name])
    |> validate_required([:username, :password, :name])
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
