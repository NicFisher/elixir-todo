defmodule Todo.Boards.BoardLists.BoardListManagerTest do
  use Todo.DataCase
  alias Todo.Boards.BoardList
  alias Todo.Boards.BoardLists.BoardListManager
  alias Todo.Factory

  setup do
    {:ok, user} = Factory.create_user("nic@hello")
    {:ok, board} = Factory.create_board(user, "First Board")

    {:ok, board: board}
  end

  describe "create" do
    test "does not accept invalid attributes", %{board: board} do
      invalid_attributes = %{
        "name" => "",
        "position" => "1",
        "archived" => false
      }

      assert {:error, "Invalid details"} == BoardListManager.create(invalid_attributes, board)
    end

    test "creates board list with valid attributes", %{board: board} do
      attributes = %{
        "name" => "First Board List",
        "position" => "1",
        "archived" => false
      }

      {:ok, board_list} = BoardListManager.create(attributes, board)

      assert board_list.name == "First Board List"
      assert board_list.position == 1
      assert board_list.archived == false
      assert Todo.Repo.aggregate(BoardList, :count) == 1
    end

    test "reorders board lists when board list is in the same position", %{board: board} do
      Factory.create_board_list(board, "Board List", "1")

      attributes = %{
        "name" => "New First Board List",
        "position" => "1",
        "archived" => false
      }

      {:ok, board_list} = BoardListManager.create(attributes, board)

      original_first_board_list = Todo.Repo.get_by(BoardList, name: "Board List")

      assert board_list.position == 1
      assert original_first_board_list.position == 2
      assert Todo.Repo.aggregate(BoardList, :count) == 2
    end

    test "reorders boards lists and leaves no gaps between positions", %{board: board} do
      Factory.create_board_list(board, "First Board List", "1")
      Factory.create_board_list(board, "Second Board List", "2")

      attributes = %{
        "name" => "New Board List",
        "position" => "4",
        "archived" => false
      }

      {:ok, board_list} = BoardListManager.create(attributes, board)

      assert board_list.position == 3
    end

    test "reorders boards lists when multiple board lists exist", %{board: board} do
      Factory.create_board_list(board, "First Board List", "1")
      Factory.create_board_list(board, "Second Board List", "2")
      Factory.create_board_list(board, "Third Board List", "3")

      attributes = %{
        "name" => "New Third Board List",
        "position" => "3",
        "archived" => false
      }

      {:ok, new_board_list} = BoardListManager.create(attributes, board)
      first_board_list = Todo.Repo.get_by(BoardList, name: "First Board List")
      second_board_list = Todo.Repo.get_by(BoardList, name: "Second Board List")
      updated_third_board_list = Todo.Repo.get_by(BoardList, name: "Third Board List")

      assert first_board_list.position == 1
      assert second_board_list.position == 2
      assert updated_third_board_list.position == 4
      assert new_board_list.position == 3
    end
  end

  describe "update" do
    test "does not accept invalid attributes", %{board: board} do
      {:ok, board_list} = Factory.create_board_list(board, "First Board List", "1")

      invalid_attributes = %{
        "name" => "",
        "position" => "1",
        "archived" => false
      }

      {:error, changeset} = BoardListManager.update(invalid_attributes, board_list)

      assert changeset.valid? == false
    end

    test "updates board list with valid attributes", %{board: board} do
      {:ok, board_list} = Factory.create_board_list(board, "First Board List", "1")

      attributes = %{
        "name" => "Updated Name",
        "position" => "1",
        "archived" => false
      }

      {:ok, board_list} = BoardListManager.update(attributes, board_list)

      assert board_list.name == "Updated Name"
    end

    test "reorders board lists when board list position decreased", %{board: board} do
      {:ok, _board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, _board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, board_list_3} = Factory.create_board_list(board, "Third Board List", "3")

      attributes = %{
        "name" => "Updated Third Board List",
        "position" => "2",
        "archived" => false
      }

      # move board_list_3 to position 2
      {:ok, _board_list} = BoardListManager.update(attributes, board_list_3)

      first_board_list = Todo.Repo.get_by(BoardList, position: 1)
      second_board_list = Todo.Repo.get_by(BoardList, position: 2)
      third_board_list = Todo.Repo.get_by(BoardList, position: 3)

      assert first_board_list.name == "First Board List"
      assert second_board_list.name == "Updated Third Board List"
      assert third_board_list.name == "Second Board List"
    end

    test "reorders board lists when board list position increased", %{board: board} do
      {:ok, _board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, _board_list_3} = Factory.create_board_list(board, "Third Board List", "3")

      attributes = %{
        "name" => "Updated Second Board List",
        "position" => "3",
        "archived" => false
      }

      # move board_list_2 to position 3
      {:ok, _board_list} = BoardListManager.update(attributes, board_list_2)

      first_board_list = Todo.Repo.get_by(BoardList, position: 1)
      second_board_list = Todo.Repo.get_by(BoardList, position: 2)
      third_board_list = Todo.Repo.get_by(BoardList, position: 3)

      assert first_board_list.name == "First Board List"
      assert second_board_list.name == "Third Board List"
      assert third_board_list.name == "Updated Second Board List"
    end

    test "reorders board lists when board list position increased by multiple", %{board: board} do
      {:ok, board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, _board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, _board_list_3} = Factory.create_board_list(board, "Third Board List", "3")
      {:ok, _board_list_4} = Factory.create_board_list(board, "Fourth Board List", "4")

      attributes = %{
        "name" => "Updated First Board List",
        "position" => "3",
        "archived" => false
      }

      # move board_list_1 to position 3
      {:ok, _board_list} = BoardListManager.update(attributes, board_list_1)

      first_board_list = Todo.Repo.get_by(BoardList, position: 1)
      second_board_list = Todo.Repo.get_by(BoardList, position: 2)
      third_board_list = Todo.Repo.get_by(BoardList, position: 3)
      fourth_board_list = Todo.Repo.get_by(BoardList, position: 4)

      assert first_board_list.name == "Second Board List"
      assert second_board_list.name == "Third Board List"
      assert third_board_list.name == "Updated First Board List"
      assert fourth_board_list.name == "Fourth Board List"
    end

    test "reorders board lists when board list position decreased by multiple", %{board: board} do
      {:ok, _board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, _board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, board_list_3} = Factory.create_board_list(board, "Third Board List", "3")
      {:ok, _board_list_4} = Factory.create_board_list(board, "Fourth Board List", "4")

      attributes = %{
        "name" => "Updated Third Board List",
        "position" => "1",
        "archived" => false
      }

      # move board_list_3 to position 1
      {:ok, _board_list} = BoardListManager.update(attributes, board_list_3)

      first_board_list = Todo.Repo.get_by(BoardList, position: 1)
      second_board_list = Todo.Repo.get_by(BoardList, position: 2)
      third_board_list = Todo.Repo.get_by(BoardList, position: 3)
      fourth_board_list = Todo.Repo.get_by(BoardList, position: 4)

      assert first_board_list.name == "Updated Third Board List"
      assert second_board_list.name == "First Board List"
      assert third_board_list.name == "Second Board List"
      assert fourth_board_list.name == "Fourth Board List"
    end

    test "cannot update list with position greater than the highest position + 1", %{board: board} do
      {:ok, board_list_1} = Factory.create_board_list(board, "First Board List", "1")
      {:ok, _board_list_2} = Factory.create_board_list(board, "Second Board List", "2")
      {:ok, _board_list_3} = Factory.create_board_list(board, "Third Board List", "3")

      attributes = %{
        "name" => "Updated First Board List",
        "position" => "6",
        "archived" => false
      }

      # move board_list_1 to position 6 when max list position is 3
      {:ok, board_list} = BoardListManager.update(attributes, board_list_1)

      assert board_list.position == 4
    end
  end
end
