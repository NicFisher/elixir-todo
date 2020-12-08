defmodule Todo.ShareBoardTokens.CreateShareBoardToken do
  alias Todo.Accounts.User
  alias Todo.Boards.Board
  alias Todo.Workers.ShareBoardEmailWorker

  def create(board_id, shared_user_email, current_user_id) do
    with {:ok, shared_user_id} <- get_user_id_by_email(shared_user_email),
         {:ok, _board} <- board_belongs_to_current_user(board_id, current_user_id),
         {:ok, share_board_token} <- Todo.Boards.create_share_board_token(board_id, shared_user_id),
         {:ok, _} <- enqueue_share_board_email_worker(share_board_token.token) do
      {:ok, share_board_token}
    else
      error -> error
    end
  end

  defp get_user_id_by_email(email) do
    case Todo.Repo.get_by(User, email: email) do
      %User{} = user -> {:ok, user.id}
      _ -> {:error, "User does not exist"}
    end
  end

  defp board_belongs_to_current_user("", _), do: {:error, "Board must be selected"}

  defp board_belongs_to_current_user(board_id, current_user_id) do
    case Todo.Repo.get_by(Board, id: board_id, user_id: current_user_id) do
      %Todo.Boards.Board{} = board -> {:ok, board}
      _ -> {:error, "Board does not belong to current user"}
    end
  end

  defp enqueue_share_board_email_worker(token) do
    ShareBoardEmailWorker.enqueue(token)
  end
end
