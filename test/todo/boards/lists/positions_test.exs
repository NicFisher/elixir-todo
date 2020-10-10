defmodule Todo.Boards.Lists.PositionsTest do
  use Todo.DataCase
  alias Todo.Boards.List
  alias Todo.Boards.Lists.Positions
  alias Todo.Factory

  setup do
    {:ok, user} = Factory.create_user("nic@hello")
    {:ok, board} = Factory.create_board(user, "First Board")

    {:ok, board: board}
  end

  describe "reorder/3" do
    test "does not update lists if updated position is equal to current position", %{board: board} do
      {:ok, _list_1} = Factory.create_list(board, "First List", "1")
      {:ok, _list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, _list_3} = Factory.create_list(board, "Third List", "3")

      multi = Positions.reorder(2, 2, board.id)
      Repo.transaction(multi)

      first_list = Todo.Repo.get_by(List, name: "First List")
      second_list = Todo.Repo.get_by(List, name: "Second List")
      third_list = Todo.Repo.get_by(List, name: "Third List")

      assert first_list.position == 1
      assert second_list.position == 2
      assert third_list.position == 3
    end

    test "updates lists when increasing list position", %{board: board} do
      {:ok, _list_1} = Factory.create_list(board, "First List", "1")
      {:ok, _list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, _list_3} = Factory.create_list(board, "Third List", "3")
      {:ok, _list_4} = Factory.create_list(board, "Fourth List", "4")

      # moving list_2 to position 3
      multi = Positions.reorder(3, 2, board.id)
      Repo.transaction(multi)

      first_list = Todo.Repo.get_by(List, name: "First List")
      third_list = Todo.Repo.get_by(List, name: "Third List")
      fourth_list = Todo.Repo.get_by(List, name: "Fourth List")

      # list_2 does not get updated in the Positions module
      assert first_list.position == 1
      assert third_list.position == 2
      assert fourth_list.position == 4
    end

    test "updates lists when decreasing list position", %{board: board} do
      {:ok, _list_1} = Factory.create_list(board, "First List", "1")
      {:ok, _list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, _list_3} = Factory.create_list(board, "Third List", "3")
      {:ok, _list_4} = Factory.create_list(board, "Fourth List", "4")

      # moving list_2 to position 1
      multi = Positions.reorder(1, 2, board.id)
      Repo.transaction(multi)

      first_list = Todo.Repo.get_by(List, name: "First List")
      third_list = Todo.Repo.get_by(List, name: "Third List")
      fourth_list = Todo.Repo.get_by(List, name: "Fourth List")

      # list_2 does not get updated in the Positions module
      assert first_list.position == 2
      assert third_list.position == 3
      assert fourth_list.position == 4
    end

    test "updates lists when current list position is nil", %{board: board} do
      {:ok, _list_1} = Factory.create_list(board, "First List", "1")
      {:ok, _list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, _list_3} = Factory.create_list(board, "Third List", "3")
      {:ok, _list_4} = Factory.create_list(board, "Fourth List", "4")

      multi = Positions.reorder(1, nil, board.id)
      Repo.transaction(multi)

      first_list = Todo.Repo.get_by(List, name: "First List")
      second_list = Todo.Repo.get_by(List, name: "Second List")
      third_list = Todo.Repo.get_by(List, name: "Third List")
      fourth_list = Todo.Repo.get_by(List, name: "Fourth List")

      assert first_list.position == 2
      assert second_list.position == 3
      assert third_list.position == 4
      assert fourth_list.position == 5
    end
  end
end
