defmodule Todo.Boards.Card do
  alias Todo.Boards.List
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "cards" do
    field :name, :string, null: false
    field :description, :string
    field :archived, :boolean, default: false
    field :due_date, :date

    belongs_to :list, List, foreign_key: :list_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:name, :description, :archived, :due_date, :list_id])
    |> validate_required([:name])
  end
end
