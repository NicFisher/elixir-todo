defmodule Todo.Boards.BoardLists.BoardListPositions do
  import Ecto.Query
  alias Ecto.Multi
  alias Todo.Boards.{BoardList}
  alias Todo.Repo

  @moduledoc """
  This modules handles updating the board positions. These are the cases handled:
  - If the updated position and current position are the same, no action is required
  - If the updated position is greater than the current position, then it will reduce
    the positions of the board lists between these values by 1. E.g. If is current position(2)
    and is updated position(5), all lists greater than 2 and less than or equal to 5 will be reduced by 1
  - If there is no list in the updated position, no action is required
  - All other cases will increase the positions of the lists greater than the updated position
  """

  def reorder(updated_position, current_position, _board_id)
      when updated_position == current_position do
    {:ok, :skip}
  end

  def reorder(updated_position, current_position, board_id)
      when current_position < updated_position do
    query =
      from bl in BoardList,
        where:
          bl.position <= ^updated_position and bl.position > ^current_position and
            bl.board_id == ^board_id,
        update: [set: [position: bl.position - 1]]

    Multi.new()
    |> Multi.update_all(:board_list_positions, query, [])
    |> Repo.transaction()
  end

  def reorder(updated_position, _exisiting_position, board_id) do
    Multi.new()
    |> Multi.run(:board_list_in_updated_position, fn _, _ ->
      board_list_in_updated_position(updated_position, board_id)
    end)
    |> Multi.run(:reorder_positions, fn
      _, %{board_list_in_updated_position: %BoardList{}} ->
        update_positions(updated_position, board_id)

      _, %{board_list_in_updated_position: nil} ->
        {:ok, :skip}
    end)
    |> Repo.transaction()
  end

  defp update_positions(updated_position, board_id) do
    query =
      from bl in BoardList,
        where: bl.position >= ^updated_position and bl.board_id == ^board_id,
        update: [set: [position: bl.position + 1]]

    Multi.new()
    |> Multi.update_all(:update, query, [])
    |> Repo.transaction()
  end

  def board_list_in_updated_position(updated_position, board_id) do
    query =
      from bl in BoardList,
        where: bl.position == ^updated_position and bl.board_id == ^board_id

    {:ok, Repo.one(query)}
  end
end
