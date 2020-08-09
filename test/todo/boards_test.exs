defmodule Todo.BoardsTest do
  use Todo.DataCase

  alias Todo.Boards

  describe "boards" do
    alias Todo.Boards.Board
    alias Todo.Accounts

    @valid_attrs %{name: "Board 1", archived: false}
    @update_attrs %{
      name: "Board 2"
    }
    @invalid_attrs %{name: nil}

    def board_fixture(attrs \\ %{}) do
      user = create_user()

      {:ok, board} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Boards.create_board(user)

      board
    end

    def create_user() do
      {:ok, user} =
        Accounts.create_user(%{password: "some password", email: "email@email.com", name: "name"})

      user
    end

    def board_user(user_id) do
      Accounts.get_user!(user_id)
    end

    test "list_boards/0 returns all boards" do
      board = board_fixture()
      assert Boards.list_boards() == [board]
    end

    test "list_boards_for_user/1 returns all boards" do
      board = board_fixture()
      assert Boards.list_boards_for_user(board.user_id) == [board]
    end

    test "get_board!/2 returns the board with given id" do
      board = board_fixture()
      assert Boards.get_board!(board.id, board.user_id) == board
    end

    test "create_board/2 with valid data creates a board" do
      user = create_user()
      assert {:ok, %Board{} = board} = Boards.create_board(@valid_attrs, user)
    end

    test "create_board/2 with invalid data returns error changeset" do
      user = create_user()
      assert {:error, %Ecto.Changeset{}} = Boards.create_board(@invalid_attrs, user)
    end

    test "update_board/2 with valid data updates the board" do
      board = board_fixture()
      assert {:ok, %Board{} = board} = Boards.update_board(board, @update_attrs)
    end

    test "update_board/2 with invalid data returns error changeset" do
      board = board_fixture()
      assert {:error, %Ecto.Changeset{}} = Boards.update_board(board, @invalid_attrs)
      assert board == Boards.get_board!(board.id, board.user_id)
    end

    test "change_board/1 returns a board changeset" do
      board = board_fixture()
      assert %Ecto.Changeset{} = Boards.change_board(board)
    end
  end
end
