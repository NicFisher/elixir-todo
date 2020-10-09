defmodule Todo.Factory do
  alias Todo.Boards.{List, Board, Card}
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

  def create_card(name, description, list) do
    list
    |> Ecto.build_assoc(:cards)
    |> Card.changeset(%{
      name: name,
      description: description
    })
    |> Repo.insert()
  end
end
