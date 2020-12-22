defmodule Todo.BoardUsers.CreateBoardUserTest do
  use Todo.DataCase
  alias Todo.BoardUsers.CreateBoardUser
  alias Todo.Boards.{BoardUser, ShareBoardToken}
  alias Todo.Factory

  setup do
    {:ok, user} = Factory.create_user("nic@hello")
    {:ok, board} = Factory.create_board(user, "Test Board")

    expiry_date = Timex.now() |> Timex.shift(days: 1)

    {:ok, %ShareBoardToken{token: token}} =
      Factory.create_share_board_token(user.id, board.id, expiry_date)

    {:ok, user: user, board: board, token: token}
  end

  describe "create/2" do
    test "creates board user with details correct", %{user: user, token: token, board: board} do
      assert {:ok, %BoardUser{} = board_user} = CreateBoardUser.create(token, user.id)
      assert board_user.board_id == board.id
      assert board_user.user_id == user.id
    end

    test "returns error when board user already exists", %{user: user, token: token, board: board} do
      {:ok, %BoardUser{}} = Factory.create_board_user(user.id, board.id)

      assert {:error, "Board has already been shared"} == CreateBoardUser.create(token, user.id)
    end

    test "returns error when token expired", %{user: user, board: board} do
      expiry_date = Timex.now() |> Timex.shift(days: -1)

      {:ok, %ShareBoardToken{token: token}} =
        Factory.create_share_board_token(user.id, board.id, expiry_date)

      assert {:error, "Token has expired. Unable to share board."} ==
               CreateBoardUser.create(token, user.id)
    end

    test "returns error when current user doesnt match share board token user", %{token: token} do
      {:ok, new_user} = Factory.create_user("new_user@hello")

      assert {:error, "Invalid user logged in. Please login with correct user."} ==
               CreateBoardUser.create(token, new_user.id)
    end
  end
end
