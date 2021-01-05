# Todo List/Trello

A very basic todo list / trello app using Elixir, Phoenix, LiveView, EctoJob, and Tailwind CSS.

**Functionality:**

- Login and logout
- Reset password
- Create, edit, and update boards, lists, and cards
- Share boards with other users
- Update account details

**Up and running:**

Elixir version = 1.7.0

Erlang version = 22.0.3

```
git clone https://github.com/NicFisher/elixir-todo.git
cd elixir-todo
mix deps.get
mix ecto.setup
cd assets && yarn install
iex -S mix phx.server
```
