defmodule Todo.ShareBoardTokens.CreateShareBoardTokenTest do
  use Todo.DataCase
  alias Todo.Boards.ShareBoardToken
  alias Todo.ShareBoardTokens.CreateShareBoardToken
  alias Todo.Factory

  setup do
    {:ok, user} = Factory.create_user("nic@hello")
    {:ok, user2} = Factory.create_user("test@hello")
    {:ok, board} = Factory.create_board(user, "First Board")

    {:ok, board: board, user: user, user2: user2}
  end

  describe "create/3" do
    test "creates a share board token and job for ShareBoardEmailWorker", %{
      board: board,
      user: user,
      user2: user2
    } do
      {:ok, %ShareBoardToken{} = share_board_token} =
        CreateShareBoardToken.create(board.id, user2.email, user.id)

      assert share_board_token.board_id == board.id
      assert share_board_token.user_id == user2.id

      [share_board_email_job] = Todo.Repo.all(Todo.JobQueue)

      assert share_board_email_job.params == %{
               "type" => "Elixir.Todo.Workers.ShareBoardEmailWorker",
               "token" => share_board_token.token
             }
    end

    test "returns an error if board does not exist", %{user: user, user2: user2} do
      assert {:error, "Board must be selected"} ==
               CreateShareBoardToken.create("", user2.email, user.id)
    end

    test "returns an error if user email does not exist", %{board: board, user: user} do
      assert {:error, "User does not exist"} ==
               CreateShareBoardToken.create(board.id, "email@email.com", user.id)
    end

    test "returns an error if board does not belong to current user", %{user: user, user2: user2} do
      {:ok, board2} = Factory.create_board(user2, "First Board")

      assert {:error, "Board does not belong to current user"} ==
               CreateShareBoardToken.create(board2.id, user2.email, user.id)
    end
  end
end
