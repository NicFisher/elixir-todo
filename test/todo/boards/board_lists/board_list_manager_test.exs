defmodule Todo.Boards.BoardLists.BoardListManagerTest do
  use Todo.DataCase
  alias Todo.Boards.{BoardList, Board}
  alias Todo.Accounts.User
  alias Todo.Boards.BoardLists.BoardListManager

  setup do
    {:ok, user} =
      Todo.Repo.insert(%User{
        id: "3f10cb63-122e-47f6-b987-2ee0b0e63446",
        email: "email@email.com",
        password: "password",
        name: "Joe Bloggs"
      })

    {:ok, board} =
      Todo.Repo.insert(%Board{
        id: "3f10cb63-122e-47f6-b987-2ee0b0e63123",
        name: "Board Numero Uno",
        archived: false,
        user: user
      })

    {:ok, board_list} =
      Todo.Repo.insert(%BoardList{
        id: "1230cb63-122e-47f6-b987-2ee0b0e63446",
        name: "Board List Numero Uno",
        archived: false,
        position: 1,
        board: board
      })

    valid_attributes = %{
      "name" => "New Board List Numero Uno",
      "position" => "1",
      "archived" => false
    }

    invalid_attributes = %{
      "name" => "",
      "position" => "1",
      "archived" => false
    }

    {:ok,
     board: board,
     board_list: board_list,
     valid_attributes: valid_attributes,
     invalid_attributes: invalid_attributes}
  end

  describe "create" do
    test "with valid attributes and exisiting board lists, it creates a new board list and updates existing board list positions",
         %{board: board, valid_attributes: valid_attributes} do
      {:ok, %BoardList{position: new_board_list_postion}} =
        BoardListManager.create(valid_attributes, board)

      original_numero_uno_board = Todo.Repo.get_by(BoardList, name: "Board List Numero Uno")

      assert new_board_list_postion == 1
      assert original_numero_uno_board.position == 2
      assert Todo.Repo.aggregate(BoardList, :count) == 2
    end

    test "with valid attributes and multiple exisiting board lists, it creates a new board list and updates existing board list positions",
         %{board: board, valid_attributes: valid_attributes} do
      Todo.Repo.insert(%BoardList{
        id: "1230cb63-122e-47f6-b987-2ee0b0e63442",
        name: "Board List Numero Dos",
        archived: false,
        position: 2,
        board: board
      })

      {:ok, %BoardList{position: new_board_list_postion}} =
        BoardListManager.create(valid_attributes, board)

      original_numero_uno_board_list = Todo.Repo.get_by(BoardList, name: "Board List Numero Uno")
      original_numero_dos_board_list = Todo.Repo.get_by(BoardList, name: "Board List Numero Dos")

      assert new_board_list_postion == 1
      assert original_numero_uno_board_list.position == 2
      assert original_numero_dos_board_list.position == 3
      assert Todo.Repo.aggregate(BoardList, :count) == 3
    end

    test "with invalid attributes and multiple existing boards, it returns an error, does not create the new board list or update existing board lists positions",
         %{board: board, invalid_attributes: invalid_attributes} do
      result = BoardListManager.create(invalid_attributes, board)
      original_numero_uno_board_list = Todo.Repo.get_by(BoardList, name: "Board List Numero Uno")

      assert result == {:error, "Invalid details"}
      assert original_numero_uno_board_list.position == 1
      assert Todo.Repo.aggregate(BoardList, :count) == 1
    end
  end

  describe "update" do
    test "with valid attributes and exisiting board lists, it updates the board list and updates existing board list positions",
         %{valid_attributes: valid_attributes, board: board} do
      {:ok, board_list} =
        Todo.Repo.insert(%BoardList{
          id: "1230cb63-444e-47f6-b987-2ee0b0e63786",
          name: "New Board List Numero Uno",
          archived: false,
          position: 2,
          board: board
        })

      {:ok, %BoardList{position: updated_board_list_postion}} =
        BoardListManager.update(valid_attributes, board_list)

      original_numero_uno_board_list = Todo.Repo.get_by(BoardList, name: "Board List Numero Uno")

      assert updated_board_list_postion == 1
      assert original_numero_uno_board_list.position == 2
    end

    test "with valid attributes and multiple exisiting board lists, it updates the board list and updates existing board list positions",
         %{valid_attributes: valid_attributes, board: board} do
      {:ok, board_list} =
        Todo.Repo.insert(%BoardList{
          id: "1230cb63-444e-47f6-b987-2ee0b0e63786",
          name: "New Board List Numero Uno",
          archived: false,
          position: 2,
          board: board
        })

      {:ok, _} =
        Todo.Repo.insert(%BoardList{
          id: "1230cb63-333e-47f6-b987-2ee0b0e63786",
          name: "New Board List Numero Dos",
          archived: false,
          position: 3,
          board: board
        })

      {:ok, %BoardList{position: updated_board_list_postion}} =
        BoardListManager.update(valid_attributes, board_list)

      original_numero_uno_board_list = Todo.Repo.get_by(BoardList, name: "Board List Numero Uno")

      original_numero_dos_board_list =
        Todo.Repo.get_by(BoardList, name: "New Board List Numero Dos")

      assert updated_board_list_postion == 1
      assert original_numero_uno_board_list.position == 2
      assert original_numero_dos_board_list.position == 4
    end

    test "with invalid attributes and multiple existing boards, it returns an error, does not update the new board list or update existing board lists positions",
         %{board_list: board_list, board: board, invalid_attributes: invalid_attributes} do
      {:ok, _} =
        Todo.Repo.insert(%BoardList{
          id: "1230cb63-444e-47f6-b987-2ee0b0e63786",
          name: "New Board List Numero Uno",
          archived: false,
          position: 2,
          board: board
        })

      {:error, changeset} = BoardListManager.update(invalid_attributes, board_list)
      new_numero_uno_board_list = Todo.Repo.get_by(BoardList, name: "New Board List Numero Uno")

      assert new_numero_uno_board_list.position == 2
      assert changeset.errors == [name: {"can't be blank", [validation: :required]}]
    end
  end
end
