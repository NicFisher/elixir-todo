defmodule Todo.Boards.BoardLists.PositionsTest do
  use Todo.DataCase
  alias Todo.Boards.BoardList
  alias Todo.Boards.BoardLists.Positions
  alias Todo.Factory

  setup do
    {:ok, user} = Factory.create_user("nic@hello")
    {:ok, board} = Factory.create_board(user, "First Board")

    {:ok, board: board}
  end

  describe "reorder/3" do
    test "does not update lists if updated position is equal to current position", %{board: board} do
      {:ok, _board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, _board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, _board_list_3} = Factory.create_board_list(board, "Third Board List", "3")

      multi = Positions.reorder(2, 2, board.id)
      Repo.transaction(multi)

      first_list = Todo.Repo.get_by(BoardList, name: "First Board List")
      second_list = Todo.Repo.get_by(BoardList, name: "Second Board List")
      third_list = Todo.Repo.get_by(BoardList, name: "Third Board List")

      assert first_list.position == 1
      assert second_list.position == 2
      assert third_list.position == 3
    end

    test "updates lists when increasing list position", %{board: board} do
      {:ok, _board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, _board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, _board_list_3} = Factory.create_board_list(board, "Third Board List", "3")
      {:ok, _board_list_4} = Factory.create_board_list(board, "Fourth Board List", "4")

      # moving board_list_2 to position 3
      multi = Positions.reorder(3, 2, board.id)
      Repo.transaction(multi)

      first_list = Todo.Repo.get_by(BoardList, name: "First Board List")
      third_list = Todo.Repo.get_by(BoardList, name: "Third Board List")
      fourth_list = Todo.Repo.get_by(BoardList, name: "Fourth Board List")

      # board_list_2 does not get updated in the Positions module
      assert first_list.position == 1
      assert third_list.position == 2
      assert fourth_list.position == 4
    end

    test "updates lists when decreasing list position", %{board: board} do
      {:ok, _board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, _board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, _board_list_3} = Factory.create_board_list(board, "Third Board List", "3")
      {:ok, _board_list_4} = Factory.create_board_list(board, "Fourth Board List", "4")

      # moving board_list_2 to position 1
      multi = Positions.reorder(1, 2, board.id)
      Repo.transaction(multi)

      first_list = Todo.Repo.get_by(BoardList, name: "First Board List")
      third_list = Todo.Repo.get_by(BoardList, name: "Third Board List")
      fourth_list = Todo.Repo.get_by(BoardList, name: "Fourth Board List")

      # board_list_2 does not get updated in the Positions module
      assert first_list.position == 2
      assert third_list.position == 3
      assert fourth_list.position == 4
    end

    test "updates lists when current list position is nil", %{board: board} do
      {:ok, _board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, _board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, _board_list_3} = Factory.create_board_list(board, "Third Board List", "3")
      {:ok, _board_list_4} = Factory.create_board_list(board, "Fourth Board List", "4")

      multi = Positions.reorder(1, nil, board.id)
      Repo.transaction(multi)

      first_list = Todo.Repo.get_by(BoardList, name: "First Board List")
      second_list = Todo.Repo.get_by(BoardList, name: "Second Board List")
      third_list = Todo.Repo.get_by(BoardList, name: "Third Board List")
      fourth_list = Todo.Repo.get_by(BoardList, name: "Fourth Board List")

      assert first_list.position == 2
      assert second_list.position == 3
      assert third_list.position == 4
      assert fourth_list.position == 5
    end
  end
end
