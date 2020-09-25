defmodule Todo.Factory do
  alias Todo.Boards.{BoardList, Board}
  alias Todo.Accounts.User
  alias Todo.Repo

  def create_user(email) do
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

  def create_board_list(board, board_list_name, position) do
    board
    |> Ecto.build_assoc(:board_lists)
    |> BoardList.changeset(%{
      name: board_list_name,
      position: position,
      archived: false
    })
    |> Repo.insert()
  end
end