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

  def card_due_date_months() do
    [
      {1, "January"},
      {2, "February"},
      {3, "March"},
      {4, "April"},
      {5, "May"},
      {6, "June"},
      {7, "July"},
      {8, "August"},
      {9, "September"},
      {10, "October"},
      {11, "November"},
      {12, "December"}
    ]
  end

  def card_due_date_years() do
    now = DateTime.now!("Etc/UTC")
    five_years_from_now = now.year + 5
    Enum.map(now.year..five_years_from_now, fn year -> year end)
  end
end
