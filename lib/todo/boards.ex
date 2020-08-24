defmodule Todo.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias Todo.Repo

  alias Todo.Boards.{Board, BoardList}

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
  Gets a single board with the board lists ordered by position for a user.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123, 12345678)
      %Board{}

      iex> get_board!(456, 12345678)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id, user_id) do
    query = from b in Todo.Boards.Board,
      left_join: bl in Todo.Boards.BoardList,
      on: b.id == bl.board_id,
      where: b.id == ^id and b.user_id == ^user_id,
      order_by: bl.position,
      preload: [board_lists: bl]

    Repo.one!(query)
  end

  @doc """
  Gets a single board list from a board for the user.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board_list!(123, 456, 789)
      %Board{}

      iex> get_board_list!(456, 123, 789)
      ** (Ecto.NoResultsError)

  """
  def get_board_list!(board_list_id, board_id, user_id) do
    query = from b in Board,
    join: bl in BoardList, on: bl.board_id == b.id,
    where: b.id == ^board_id and b.user_id == ^user_id and bl.id == ^board_list_id and bl.archived == false,
    select: bl

    Repo.one!(query)

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
  Creates a board list for a board.

  ## Examples

      iex> create_board_list(%{field: value}, %Board{})
      {:ok, %BoardList{}}

      iex> create_board_list(%{field: bad_value}, %Board{})
      {:error, %Ecto.Changeset{}}

  """
  def create_board_list(attrs \\ %{}, board) do
    board
    |> Ecto.build_assoc(:board_lists)
    |> BoardList.changeset(attrs)
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
  Updates a board list.

  ## Examples

      iex> update_board_list(board_list, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board_list(board_list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board_list(%BoardList{} = board_list, attrs) do
    board_list
    |> BoardList.changeset(attrs)
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board list changes.

  ## Examples

      iex> change_board_list(board_list)
      %Ecto.Changeset{data: %BoardList{}}

  """
  def change_board_list(%BoardList{} = board_list, attrs \\ %{}) do
    BoardList.changeset(board_list, attrs)
  end
end
