defmodule Todo.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias Todo.Repo

  alias Todo.Boards.{Board, List, Lists.ListManager, Card}

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
  Gets a single board with the lists and cards for a user. The lists are ordered by list position.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123, 12345678)
      %Board{}

      iex> get_board!(456, 12345678)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id, user_id) do
    query =
      from board in Todo.Boards.Board,
        where: board.id == ^id and board.user_id == ^user_id,
        left_join: lists in assoc(board, :lists),
        left_join: cards in assoc(lists, :cards),
        order_by: [asc: lists.position, desc: cards.inserted_at],
        preload: [lists: {lists, cards: cards}]

    Repo.one!(query)
  end

  @doc """
  Gets a single list from a board for the user.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_list!(123, 456, 789)
      %Board{}

      iex> get_list!(456, 123, 789)
      ** (Ecto.NoResultsError)

  """
  def get_list!(list_id, board_id, user_id) do
    query =
      from b in Board,
        join: bl in List,
        on: bl.board_id == b.id,
        where:
          b.id == ^board_id and b.user_id == ^user_id and bl.id == ^list_id and
            bl.archived == false,
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
  Creates a list for a board.

  ## Examples

      iex> create_list(%{field: value}, %Board{})
      {:ok, %List{}}

      iex> create_list(%{field: bad_value}, %Board{})
      {:error, "error message"}

  """
  def create_list(attrs \\ %{}, board) do
    ListManager.create(attrs, board)
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %Board{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    ListManager.update(attrs, list)
  end

  @doc """
  Creates a card for a list.

  ## Examples

      iex> create_card(%{field: value}, %Card{})
      {:ok, %Board{}}

      iex> create_card(%{field: bad_value}, %Card{})
      {:error, %Ecto.Changeset{}}

  """
  def create_card(attrs \\ %{}, list) do
    list
    |> Ecto.build_assoc(:cards)
    |> Card.changeset(attrs)
    |> Repo.insert()
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
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{data: %List{}}

  """
  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking card changes.

  ## Examples

      iex> change_card(card)
      %Ecto.Changeset{data: %Card{}}

  """
  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end
end
