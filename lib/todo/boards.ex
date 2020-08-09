defmodule Todo.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias Todo.Repo

  alias Todo.Boards.Board

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards()
      [%Board{}, ...]

  """
  def list_boards do
    Repo.all(Board)
  end

  @doc """
  Returns list of boards for a specific user.

  ## Examples

      iex> list_boards_for_user(123)
      [%Board{}, ...]

  """
  def list_boards_for_user(user_id) do
    from(b in Board,
      where: b.user_id == ^user_id,
      where: b.archived == false,
      order_by: [desc: b.updated_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single board for a user.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123, 12345678)
      %Board{}

      iex> get_board!(456, 12345678)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id, user_id) do
    Repo.get_by(Board, id: id, user_id: user_id)
  end

  @doc """
  Creates a board for a user.

  ## Examples

      iex> create_board(%{field: value}, %User{})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}, user) do
    user
    |> Ecto.build_assoc(:boards)
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end
end
