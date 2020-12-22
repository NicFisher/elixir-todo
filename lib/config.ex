defmodule Todo.Config do
  def send_grid_api_key(), do: Application.get_env(:todo, :send_grid_api_key)
  def send_grid_url(), do: Application.get_env(:todo, :send_grid_url)
  def base_url(), do: Application.get_env(:todo, :base_url)
end
