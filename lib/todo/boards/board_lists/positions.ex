defmodule Todo.Boards.Lists.Positions do
  import Ecto.Query
  alias Ecto.Multi
  alias Todo.Boards.{List}
  alias Todo.Repo

  defguard is_equal(value1, value2)
           when value1 == value2 and is_integer(value1) and is_integer(value2)

  defguard is_greater_than(value1, value2)
           when value1 > value2 and is_integer(value1) and is_integer(value2)

  @moduledoc """
  This modules handles updating the board positions. These are the cases handled:
  - If the updated position and current position are the same, no action is required
  - If there is no list in the updated position, no action is required
  - If the updated position is greater than the current position, then it will reduce
    the positions of the lists between these values by 1. E.g. If is current position(2)
    and is updated position(5), all lists greater than 2 and less than or equal to 5 will be reduced by 1
  - If the updated position is less than the current position, then it will increase
    the positions of the lists between these values by 1. E.g. If is current position(6)
    and is updated position(3), all lists greater than or equal to 3 and less than or 6 will be increased by 1
  - All other cases will increase the positions of the lists greater than the updated position
  """

  @spec reorder(Integer.t(), Integer.t(), Integer.t()) :: Multi.t()
  def reorder(updated_position, current_position, _board_id)
      when is_equal(updated_position, current_position) do
    Multi.new()
  end

  def reorder(updated_position, current_position, board_id) do
    Multi.new()
    |> Multi.run(:list_in_updated_position, fn _, _ ->
      list_in_updated_position(updated_position, board_id)
    end)
    |> Multi.merge(fn
      %{list_in_updated_position: %List{}} ->
        update_positions(updated_position, current_position, board_id)

      %{list_in_updated_position: nil} ->
        Multi.new()
    end)
  end

  defp update_positions(updated_position, current_position, board_id)
       when is_greater_than(updated_position, current_position) do
    query =
      from bl in List,
        where:
          bl.board_id == ^board_id and
            bl.position <= ^updated_position and bl.position > ^current_position,
        update: [set: [position: bl.position - 1]]

    Multi.new()
    |> Multi.update_all(:list_positions, query, [])
  end

  defp update_positions(updated_position, current_position, board_id)
       when is_greater_than(current_position, updated_position) do
    query =
      from bl in List,
        where:
          bl.board_id == ^board_id and
            bl.position >= ^updated_position and bl.position < ^current_position,
        update: [set: [position: bl.position + 1]]

    Multi.new()
    |> Multi.update_all(:list_positions, query, [])
  end

  defp update_positions(updated_position, _current_position, board_id) do
    query =
      from bl in List,
        where: bl.board_id == ^board_id and bl.position >= ^updated_position,
        update: [set: [position: bl.position + 1]]

    Multi.new()
    |> Multi.update_all(:list_positions, query, [])
  end

  def list_in_updated_position(updated_position, board_id) do
    query =
      from bl in List,
        where: bl.board_id == ^board_id and bl.position == ^updated_position

    {:ok, Repo.one(query)}
  end
end
