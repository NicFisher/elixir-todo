defmodule Todo.Accounts.ResetPasswordToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias Todo.Accounts.User
  alias Todo.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "reset_password_tokens" do
    field :token, :string, null: false
    field :expiry_date, :utc_datetime, null: false
    field :used, :boolean, null: false, default: false

    belongs_to :user, User, foreign_key: :user_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(reset_password_token, attrs) do
    reset_password_token
    |> cast(attrs, [:user_id, :token, :expiry_date, :used])
    |> validate_required([:user_id, :token, :expiry_date])
    |> assoc_constraint(:user)
  end

  def validate(token) do
    with %__MODULE__{} = reset_password_token <- get_reset_password_token(token),
         true <- not_expired?(reset_password_token),
         true <- not_used?(reset_password_token) do
      {:ok, reset_password_token}
    else
      {false, error} -> {:error, error}
      _ -> {:error, "Reset password link is invalid."}
    end
  end

  defp get_reset_password_token(token) do
    Todo.Repo.get_by(__MODULE__, token: token) |> Repo.preload(:user)
  end

  defp not_expired?(share_board_token) do
    case DateTime.compare(share_board_token.expiry_date, Timex.now()) do
      :lt -> {false, "Reset password link has expired."}
      _ -> true
    end
  end

  defp not_used?(reset_password_token) do
    case !reset_password_token.used do
      false -> {false, "Reset password link has already been used."}
      true -> true
    end
  end
end
