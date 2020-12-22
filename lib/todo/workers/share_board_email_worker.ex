defmodule Todo.Workers.ShareBoardEmailWorker do
  alias Todo.Config
  alias Todo.{Boards.ShareBoardToken, Repo, Mailer.SendEmail}
  alias Ecto.Multi

  def new(token) do
    %{"type" => to_string(__MODULE__), "token" => token}
  end

  def enqueue(token) do
    new(token)
    |> Todo.JobQueue.new()
    |> Todo.Repo.insert()
  end

  def perform(%Ecto.Multi{} = multi, %{"token" => token}) do
    multi
    |> Multi.run(:share_board_token, fn _, _ -> get_share_board_token(token) end)
    |> Multi.run(:send_email, fn _, %{share_board_token: share_board_token} ->
      send_email(share_board_token)
    end)
    |> Todo.Repo.transaction()
  end

  defp get_share_board_token(token) do
    case Repo.get_by(ShareBoardToken, token: token) |> Repo.preload([:user, :board]) do
      nil -> {:error, "Unable to find share board token"}
      share_board_token -> {:ok, share_board_token}
    end
  end

  defp send_email(%ShareBoardToken{
         user: %{email: email, name: user_name},
         board: %{name: board_name},
         token: token
       }) do
    SendEmail.perform(email, user_name, email_subject(), email_content(board_name, token))
  end

  defp send_email(_) do
    {:error, "Invalid share board token details"}
  end

  defp email_subject() do
    "Elixir Todo List - Shared Board"
  end

  # add a config here for the app_base_url
  defp email_content(board_name, token) do
    """
    <html>
    <head></head>
    <body>
    The board <b>#{board_name}</b> has been shared with you.<br>
    Select the below link to view this board.
    <br><br>

    #{Config.base_url()}/share-board/activate?token=#{token}

    <br>
    Note: This link will expire in 24 hours.
    </body>
    </html>
    """
  end
end
