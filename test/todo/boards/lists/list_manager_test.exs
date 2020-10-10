defmodule Todo.Boards.Lists.ListManagerTest do
  use Todo.DataCase
  alias Todo.Boards.List
  alias Todo.Boards.Lists.ListManager
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

      assert {:error, "Invalid details"} == ListManager.create(invalid_attributes, board)
    end

    test "creates list with valid attributes", %{board: board} do
      attributes = %{
        "name" => "First List",
        "position" => "1",
        "archived" => false
      }

      {:ok, list} = ListManager.create(attributes, board)

      assert list.name == "First List"
      assert list.position == 1
      assert list.archived == false
      assert Todo.Repo.aggregate(List, :count) == 1
    end

    test "reorders lists when list is in the same position", %{board: board} do
      Factory.create_list(board, "list", "1")

      attributes = %{
        "name" => "New First list",
        "position" => "1",
        "archived" => false
      }

      {:ok, list} = ListManager.create(attributes, board)

      original_first_list = Todo.Repo.get_by(List, name: "list")

      assert list.position == 1
      assert original_first_list.position == 2
      assert Todo.Repo.aggregate(List, :count) == 2
    end

    test "reorders boards lists and leaves no gaps between positions", %{board: board} do
      Factory.create_list(board, "First list", "1")
      Factory.create_list(board, "Second List", "2")

      attributes = %{
        "name" => "New List",
        "position" => "4",
        "archived" => false
      }

      {:ok, list} = ListManager.create(attributes, board)

      assert list.position == 3
    end

    test "reorders boards lists when multiple lists exist", %{board: board} do
      Factory.create_list(board, "First List", "1")
      Factory.create_list(board, "Second List", "2")
      Factory.create_list(board, "Third List", "3")

      attributes = %{
        "name" => "New Third List",
        "position" => "3",
        "archived" => false
      }

      {:ok, new_list} = ListManager.create(attributes, board)
      first_list = Todo.Repo.get_by(List, name: "First List")
      second_list = Todo.Repo.get_by(List, name: "Second List")
      updated_third_list = Todo.Repo.get_by(List, name: "Third List")

      assert first_list.position == 1
      assert second_list.position == 2
      assert updated_third_list.position == 4
      assert new_list.position == 3
    end
  end

  describe "update" do
    test "does not accept invalid attributes", %{board: board} do
      {:ok, list} = Factory.create_list(board, "First List", "1")

      invalid_attributes = %{
        "name" => "",
        "position" => "1",
        "archived" => false
      }

      {:error, changeset} = ListManager.update(invalid_attributes, list)

      assert changeset.valid? == false
    end

    test "updates list with valid attributes", %{board: board} do
      {:ok, list} = Factory.create_list(board, "First List", "1")

      attributes = %{
        "name" => "Updated Name",
        "position" => "1",
        "archived" => false
      }

      {:ok, list} = ListManager.update(attributes, list)

      assert list.name == "Updated Name"
    end

    test "reorders lists when list position decreased", %{board: board} do
      {:ok, _list_1} = Factory.create_list(board, "First List", "1")
      {:ok, _list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, list_3} = Factory.create_list(board, "Third List", "3")

      attributes = %{
        "name" => "Updated Third List",
        "position" => "2",
        "archived" => false
      }

      # move list_3 to position 2
      {:ok, _list} = ListManager.update(attributes, list_3)

      first_list = Todo.Repo.get_by(List, position: 1)
      second_list = Todo.Repo.get_by(List, position: 2)
      third_list = Todo.Repo.get_by(List, position: 3)

      assert first_list.name == "First List"
      assert second_list.name == "Updated Third List"
      assert third_list.name == "Second List"
    end

    test "reorders lists when list position increased", %{board: board} do
      {:ok, _list_1} = Factory.create_list(board, "First List", "1")
      {:ok, list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, _list_3} = Factory.create_list(board, "Third List", "3")

      attributes = %{
        "name" => "Updated Second List",
        "position" => "3",
        "archived" => false
      }

      # move list_2 to position 3
      {:ok, _list} = ListManager.update(attributes, list_2)

      first_list = Todo.Repo.get_by(List, position: 1)
      second_list = Todo.Repo.get_by(List, position: 2)
      third_list = Todo.Repo.get_by(List, position: 3)

      assert first_list.name == "First List"
      assert second_list.name == "Third List"
      assert third_list.name == "Updated Second List"
    end

    test "reorders lists when list position increased by multiple", %{board: board} do
      {:ok, list_1} = Factory.create_list(board, "First List", "1")
      {:ok, _list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, _list_3} = Factory.create_list(board, "Third List", "3")
      {:ok, _list_4} = Factory.create_list(board, "Fourth List", "4")

      attributes = %{
        "name" => "Updated First List",
        "position" => "3",
        "archived" => false
      }

      # move list_1 to position 3
      {:ok, _list} = ListManager.update(attributes, list_1)

      first_list = Todo.Repo.get_by(List, position: 1)
      second_list = Todo.Repo.get_by(List, position: 2)
      third_list = Todo.Repo.get_by(List, position: 3)
      fourth_list = Todo.Repo.get_by(List, position: 4)

      assert first_list.name == "Second List"
      assert second_list.name == "Third List"
      assert third_list.name == "Updated First List"
      assert fourth_list.name == "Fourth List"
    end

    test "reorders lists when list position decreased by multiple", %{board: board} do
      {:ok, _list_1} = Factory.create_list(board, "First List", "1")
      {:ok, _list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, list_3} = Factory.create_list(board, "Third List", "3")
      {:ok, _list_4} = Factory.create_list(board, "Fourth List", "4")

      attributes = %{
        "name" => "Updated Third List",
        "position" => "1",
        "archived" => false
      }

      # move list_3 to position 1
      {:ok, _list} = ListManager.update(attributes, list_3)

      first_list = Todo.Repo.get_by(List, position: 1)
      second_list = Todo.Repo.get_by(List, position: 2)
      third_list = Todo.Repo.get_by(List, position: 3)
      fourth_list = Todo.Repo.get_by(List, position: 4)

      assert first_list.name == "Updated Third List"
      assert second_list.name == "First List"
      assert third_list.name == "Second List"
      assert fourth_list.name == "Fourth List"
    end

    test "cannot update list with position greater than the highest position + 1", %{board: board} do
      {:ok, list_1} = Factory.create_list(board, "First List", "1")
      {:ok, _list_2} = Factory.create_list(board, "Second List", "2")
      {:ok, _list_3} = Factory.create_list(board, "Third List", "3")

      attributes = %{
        "name" => "Updated First List",
        "position" => "6",
        "archived" => false
      }

      # move list_1 to position 6 when max list position is 3
      {:ok, list} = ListManager.update(attributes, list_1)

      assert list.position == 4
    end
  end
end
