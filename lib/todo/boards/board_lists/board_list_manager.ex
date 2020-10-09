defmodule Todo.Boards.Lists.ListManager do
  alias Ecto.Multi
  alias Todo.Boards.{Board, List}
  alias Todo.Boards.Lists.Positions
  alias Todo.Repo
  import Ecto.Query

  @moduledoc """
  This module handles creating and updating lists. When a list is created or updated,
  the positions of the other lists on that board will be re-ordered if required.
  """

  @spec create(%{}, %Board{}) :: {:ok, %List{}} | {:error, String.t()}
  def create(%{"position" => position} = attrs, board) do
    with position <- String.to_integer(position),
         attrs <- validate_updated_list_position(attrs, board.id, position, nil),
         %{valid?: true} = list_changeset <- insert_bl_changeset(attrs, board),
         {:ok, %{list: list}} <-
           insert_list_and_positions(list_changeset, position, board.id) do
      {:ok, list}
    else
      %{valid?: false} ->
        {:error, "Invalid details"}

      _error ->
        {:error, "Unable to create list"}
    end
  end

  @spec update(%{}, %List{}) ::
          {:ok, %List{}} | {:error, String.t()} | {:error, %Ecto.Changeset{}}
  def update(
        %{"position" => updated_position} = attrs,
        %List{board_id: board_id, position: current_position} = list
      ) do
    with updated_position <- String.to_integer(updated_position),
         attrs <-
           validate_updated_list_position(attrs, board_id, updated_position, current_position),
         %{valid?: true} = list_changeset <- update_bl_changeset(attrs, list),
         {:ok, %{list: list}} <-
           update_list_and_positions(
             list_changeset,
             current_position,
             updated_position,
             board_id
           ) do
      {:ok, list}
    else
      %{valid?: false} = changeset ->
        {:error, changeset}

      _error ->
        {:error, "Unable to create list"}
    end
  end

  defp update_list_and_positions(
         list_changeset,
         current_position,
         updated_position,
         board_id
       ) do
    Multi.new()
    |> Multi.merge(fn _ ->
      Positions.reorder(updated_position, current_position, board_id)
    end)
    |> Multi.update(:list, list_changeset)
    |> Repo.transaction()
  end

  defp insert_list_and_positions(list_changeset, position, board_id) do
    Multi.new()
    |> Multi.merge(fn _ ->
      Positions.reorder(position, nil, board_id)
    end)
    |> Multi.insert(:list, list_changeset)
    |> Repo.transaction()
  end

  def insert_bl_changeset(attrs, board) do
    board
    |> Ecto.build_assoc(:lists)
    |> List.changeset(attrs)
  end

  def update_bl_changeset(attrs, list) do
    list
    |> List.changeset(attrs)
  end

  def validate_updated_list_position(attrs, _board_id, updated_position, current_position)
      when updated_position == current_position,
      do: attrs

  # this will compare the highest list position with the updated position. If the updated_position is greater than the highest list position plus 1,
  # it will update the position in the attrs to highest list position + 1. E.g. if updated_position is 10, but the highest list position is 5,
  # then the attrs position will be changed to 6. All other cases will return original attrs.
  def validate_updated_list_position(attrs, board_id, updated_position, _current_position) do
    query =
      from bl in List,
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
