defmodule Todo.Boards.BoardLists.BoardListManager do
  alias Ecto.Multi
  alias Todo.Boards.{Board, BoardList}
  alias Todo.Boards.BoardLists.BoardListPositions
  alias Todo.Repo
  import Ecto.Query

  @moduledoc """
  This module handles creating and updating board lists. When a board list is created or updated,
  the positions of the other board lists on that board will be re-ordered if required.
  """

  @spec create(%{}, %Board{}) :: {:ok, %BoardList{}} | {:error, String.t()}
  def create(%{"position" => position} = attrs, board) do
    with position <- String.to_integer(position),
         attrs <- validate_updated_list_position(attrs, board.id, position, nil),
         %{valid?: true} = board_list_changeset <- insert_bl_changeset(attrs, board),
         {:ok, %{board_list: board_list}} <-
           insert_board_list_and_positions(board_list_changeset, position, board.id) do
      {:ok, board_list}
    else
      %{valid?: false} ->
        {:error, "Invalid details"}

      _error ->
        {:error, "Unable to create board list"}
    end
  end

  @spec update(%{}, %BoardList{}) ::
          {:ok, %BoardList{}} | {:error, String.t()} | {:error, %Ecto.Changeset{}}
  def update(
        %{"position" => updated_position} = attrs,
        %BoardList{board_id: board_id, position: current_position} = board_list
      ) do
    with updated_position <- String.to_integer(updated_position),
         attrs <-
           validate_updated_list_position(attrs, board_id, updated_position, current_position),
         %{valid?: true} = board_list_changeset <- update_bl_changeset(attrs, board_list),
         {:ok, %{board_list: board_list}} <-
           update_board_list_and_positions(
             board_list_changeset,
             current_position,
             updated_position,
             board_id
           ) do
      {:ok, board_list}
    else
      %{valid?: false} = changeset ->
        {:error, changeset}

      _error ->
        {:error, "Unable to create board list"}
    end
  end

  defp update_board_list_and_positions(
         board_list_changeset,
         current_position,
         updated_position,
         board_id
       ) do
    Multi.new()
    |> Multi.merge(fn _ ->
      BoardListPositions.reorder(updated_position, current_position, board_id)
    end)
    |> Multi.update(:board_list, board_list_changeset)
    |> Repo.transaction()
  end

  defp insert_board_list_and_positions(board_list_changeset, position, board_id) do
    Multi.new()
    |> Multi.merge(fn _ ->
      BoardListPositions.reorder(position, nil, board_id)
    end)
    |> Multi.insert(:board_list, board_list_changeset)
    |> Repo.transaction()
  end

  def insert_bl_changeset(attrs, board) do
    board
    |> Ecto.build_assoc(:board_lists)
    |> BoardList.changeset(attrs)
  end

  def update_bl_changeset(attrs, board_list) do
    board_list
    |> BoardList.changeset(attrs)
  end

  def validate_updated_list_position(attrs, _board_id, updated_position, current_position)
      when updated_position == current_position,
      do: attrs

  # this will compare the highest list position with the updated attrs position and change the attrs if it is great than the highest position + 1.
  # E.g. if updated_position is 10, but the highest list position is 5, then the attrs position will be changed to 6. All other cases will return orginal attrs.
  def validate_updated_list_position(attrs, board_id, updated_position, _current_position) do
    query =
      from bl in BoardList,
        where: bl.board_id == ^board_id,
        order_by: [desc: bl.position],
        select: bl.position,
        limit: 1

    highest_list_position = Repo.one(query)

    case highest_list_position do
      hlp when hlp == nil -> attrs
      hlp when hlp + 1 >= updated_position -> attrs
      hlp -> %{attrs | "position" => Integer.to_string(hlp + 1)}
    end
  end
end
