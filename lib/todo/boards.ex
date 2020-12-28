defmodule Todo.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias Todo.Repo
  alias Todo.Boards.{Board, List, Lists.ListManager, Card, BoardUser, ShareBoardToken}

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
  Returns list of shared boards for a specific user.

  ## Examples

      iex> list_shared_boards_for_user(123)
      [%Board{}, ...]

  """
  def list_shared_boards_for_user(user_id) do
    from(u in Todo.Accounts.User,
      where: u.id == ^user_id,
      join: shared_boards in assoc(u, :shared_boards),
      on: shared_boards.archived == false,
      select: shared_boards,
      order_by: [desc: shared_boards.updated_at]
    )
    |> Todo.Repo.all()
  end

  @doc """
  Gets a single board without the lists and cards.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_only_board!(123, 12345678)
      %Board{}

      iex> get_only_board!(456, 12345678)
      ** (Ecto.NoResultsError)

  """
  def get_only_board!(id, user_id) do
    query =
      from board in Todo.Boards.Board,
        where: board.id == ^id and board.user_id == ^user_id

    Repo.one!(query)
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
        left_join: lists in Todo.Boards.List,
        on: lists.board_id == board.id and lists.archived == false,
        left_join: cards in Todo.Boards.Card,
        on: cards.list_id == lists.id and cards.archived == false,
        where: board.id == ^id and board.user_id == ^user_id,
        order_by: [asc: lists.position, desc: cards.inserted_at],
        preload: [lists: {lists, cards: cards}]

    Repo.one!(query)
  end

  @doc """
  Gets a single shared board without cards or lists.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_only_shared_board!(123, 12345678)
      %Board{}

      iex> get_only_shared_board!(456, 12345678)
      ** (Ecto.NoResultsError)

  """
  def get_only_shared_board!(id, user_id) do
    query =
      from board in Todo.Boards.Board,
        join: board_users in Todo.Boards.BoardUser,
        on: board_users.board_id == ^id and board_users.user_id == ^user_id,
        where: board.id == ^id

    Repo.one!(query)
  end

  @doc """
  Gets a single shared board from the shared boards with the lists and cards for a user. The lists are ordered by list position.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_shared_board!(123, 12345678)
      %Board{}

      iex> get_shared_board!(456, 12345678)
      ** (Ecto.NoResultsError)

  """
  def get_shared_board!(id, user_id) do
    query =
      from board in Todo.Boards.Board,
        join: board_users in Todo.Boards.BoardUser,
        on: board_users.board_id == ^id and board_users.user_id == ^user_id,
        left_join: lists in Todo.Boards.List,
        on: lists.board_id == board.id and lists.archived == false,
        left_join: cards in Todo.Boards.Card,
        on: cards.list_id == lists.id and cards.archived == false,
        where: board.id == ^id,
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
  Gets a single shared board list from a board for the user.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_shared_board_list!(123, 456, 789)
      %Board{}

      iex> get_shared_board_list!(456, 123, 789)
      ** (Ecto.NoResultsError)

  """
  def get_shared_board_list!(list_id, board_id, user_id) do
    query =
      from b in Board,
        join: board_users in Todo.Boards.BoardUser,
        on: board_users.board_id == ^board_id and board_users.user_id == ^user_id,
        join: bl in List,
        on: bl.board_id == b.id,
        where:
          b.id == ^board_id and bl.id == ^list_id and
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

  @doc """
  Updates a card.

  ## Examples

      iex> update_card(card, %{field: new_value})
      {:ok, %Board{}}

      iex> update_card(card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Creates a board user.

  ## Examples

      iex> create_board_user("1234", "5678")
      {:ok, %BoardUser{}}

      iex> create_board_user("1234", "5678")
      {:error, %Ecto.Changeset{}}

  """
  def create_board_user(user_id, board_id) do
    BoardUser.changeset(%Todo.Boards.BoardUser{}, %{user_id: user_id, board_id: board_id})
    |> Repo.insert()
  end

  @doc """
  Creates a share board token.

  ## Examples

      iex> create_share_board_token("1234", "5678")
      {:ok, %ShareBoardToken{}}

      iex> create_share_board_token("1234", "5678")
      {:error, %Ecto.Changeset{}}

  """
  def create_share_board_token(board_id, user_id) do
    expiry_date = Timex.now() |> Timex.shift(days: 1)

    ShareBoardToken.changeset(%ShareBoardToken{}, %{
      user_id: user_id,
      board_id: board_id,
      token: create_token(),
      expiry_date: expiry_date
    })
    |> Repo.insert()
  end

  defp create_token do
    :crypto.strong_rand_bytes(30)
    |> Base.encode64(padding: false)
    |> String.replace(["+", "/"], "")
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking share board token changes.

  ## Examples

      iex> change_share_board_token(board)
      %Ecto.Changeset{data: %ShareBoardToken{}}

  """
  def change_share_board_token(%ShareBoardToken{} = share_board_token, attrs \\ %{}) do
    ShareBoardToken.changeset(share_board_token, attrs)
  end
end
