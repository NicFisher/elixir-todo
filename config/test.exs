use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :todo, Todo.Repo,
  username: "postgres",
  password: "postgres",
  database: "todo_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :todo, TodoWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :todo, :send_grid_api_key, "12345"
config :todo, :send_grid_url, "http://localhost:4000/v3/mail/send"
config :bypass, enable_debug_log: true
