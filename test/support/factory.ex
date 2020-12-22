defmodule Todo.Factory do
  alias Todo.Boards.{List, Board, Card, BoardUser, ShareBoardToken}
  alias Todo.Accounts.User
  alias Todo.Repo

  def create_user(email \\ "email@email.com") do
    %User{}
    |> User.changeset(%{
      email: email,
      name: "Joe Bloggs",
      password: "password"
    })
    |> Repo.insert()
  end

  def create_board(user, board_name) do
    user
    |> Ecto.build_assoc(:boards)
    |> Board.changeset(%{
      user: user,
      name: board_name,
      archived: false
    })
    |> Repo.insert()
  end

  def create_list(board, list_name, position) do
    board
    |> Ecto.build_assoc(:lists)
    |> List.changeset(%{
      name: list_name,
      position: position,
      archived: false
    })
    |> Repo.insert()
  end

  def create_card(name, description, list, due_date \\ nil) do
    list
    |> Ecto.build_assoc(:cards)
    |> Card.changeset(%{
      name: name,
      description: description,
      due_date: due_date
    })
    |> Repo.insert()
  end

  def create_board_user(user_id, board_id) do
    BoardUser.changeset(%Todo.Boards.BoardUser{}, %{user_id: user_id, board_id: board_id})
    |> Repo.insert()
  end

  def create_share_board_token(user_id, board_id, expiry_date) do
    ShareBoardToken.changeset(%ShareBoardToken{}, %{
      user_id: user_id,
      board_id: board_id,
      token: create_token(),
      expiry_date: expiry_date
    })
    |> Repo.insert()
  end

  defp create_token do
    :crypto.strong_rand_bytes(30)
    |> Base.encode64(padding: false)
    |> String.replace("+", "")
  end
end
