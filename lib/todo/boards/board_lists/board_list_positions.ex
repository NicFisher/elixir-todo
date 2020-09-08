defmodule Todo.Boards.BoardLists.BoardListPositions do
  import Ecto.Query
  alias Ecto.Multi
  alias Todo.Boards.{BoardList}
  alias Todo.Repo

  @moduledoc """
  This modules handles updating the board positions. These are the cases handled:
  - If the updated position and current position are the same, no action is required
  - If there is no list in the updated position, no action is required
  - If the updated position is greater than the current position, then it will reduce
    the positions of the board lists between these values by 1. E.g. If is current position(2)
    and is updated position(5), all lists greater than 2 and less than or equal to 5 will be reduced by 1
  - If the updated position is less than the current position, then it will increase
    the positions of the board lists between these values by 1. E.g. If is current position(6)
    and is updated position(3), all lists greater than or equal to 3 and less than or 6 will be increased by 1
  - All other cases will increase the positions of the lists greater than the updated position
  """

  def reorder(updated_position, current_position, _board_id)
      when updated_position == current_position do
    Multi.new()
  end

  def reorder(updated_position, current_position, board_id) do
    Multi.new()
    |> Multi.run(:board_list_in_updated_position, fn _, _ ->
      board_list_in_updated_position(updated_position, board_id)
    end)
    |> Multi.merge(fn
      %{board_list_in_updated_position: %BoardList{}} ->
        update_positions(updated_position, current_position, board_id)

      %{board_list_in_updated_position: nil} ->
        Multi.new()
    end)
  end

  defp update_positions(updated_position, current_position, board_id)
      when current_position < updated_position do
    query =
      from bl in BoardList,
        where:
          bl.board_id == ^board_id and
          bl.position <= ^updated_position and bl.position > ^current_position,
        update: [set: [position: bl.position - 1]]

    Multi.new()
    |> Multi.update_all(:board_list_positions, query, [])
  end

  defp update_positions(updated_position, current_position, board_id)
      when updated_position < current_position  do
    query =
      from bl in BoardList,
        where:
          bl.board_id == ^board_id and
          bl.position >= ^updated_position and bl.position < ^current_position,
        update: [set: [position: bl.position + 1]]

    Multi.new()
    |> Multi.update_all(:board_list_positions, query, [])
  end

  defp update_positions(updated_position, _current_position, board_id) do
    query =
      from bl in BoardList,
        where: bl.board_id == ^board_id and bl.position >= ^updated_position,
        update: [set: [position: bl.position + 1]]

    Multi.new()
    |> Multi.update_all(:board_list_positions, query, [])
  end

  def board_list_in_updated_position(updated_position, board_id) do
    query =
      from bl in BoardList,
        where: bl.board_id == ^board_id and bl.position == ^updated_position

    {:ok, Repo.one(query)}
  end
end
