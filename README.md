# Todo

A phoenix application similar to Trello. Users can create a board with custom columns and add cards to the board. They are also able to create a team and share boards within the team.

```
git@github.com:NicFisher/elixir-todo.git
cd todo
mix deps.get
mix ecto.setup
cd apps/aegis_web/assets && npm install
iex -S mix phx.server
```

Tailwind CSS is used for the styling.