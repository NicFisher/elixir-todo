defmodule Todo.BoardUsers.CreateBoardUser do
  alias Todo.Repo
  alias Todo.Boards.{ShareBoardToken, BoardUser}
  alias Todo.Boards

  def create(token, current_user_id) do
    with %ShareBoardToken{user_id: user_id} = share_board_token <- get_share_board_token(token),
         true <- board_user_does_not_exist?(share_board_token),
         true <- expired?(share_board_token),
         true <- user_id_matches_share_board_token_user(user_id, current_user_id),
         {:ok, board_user} <- create_board_user(share_board_token) do
      {:ok, board_user}
    else
      {false, message} -> {:error, message}
      _ -> {:error, "Unable to share board."}
    end
  end

  defp board_user_does_not_exist?(%ShareBoardToken{user_id: user_id, board_id: board_id}) do
    case Repo.get_by(BoardUser, user_id: user_id, board_id: board_id) do
      nil -> true
      _ -> {false, "Board has already been shared"}
    end
  end

  defp expired?(share_board_token) do
    case DateTime.compare(share_board_token.expiry_date, Timex.now()) do
      :lt -> {false, "Token has expired. Unable to share board."}
      _ -> true
    end
  end

  defp user_id_matches_share_board_token_user(user_id, current_user_id) do
    case user_id === current_user_id do
      false -> {false, "Invalid user logged in. Please login with correct user."}
      true -> true
    end
  end

  defp get_share_board_token(token) do
    Repo.get_by(ShareBoardToken, token: token)
  end

  defp create_board_user(%ShareBoardToken{user_id: user_id, board_id: board_id}) do
    Boards.create_board_user(user_id, board_id)
  end
end
