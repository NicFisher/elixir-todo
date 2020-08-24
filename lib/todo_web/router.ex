defmodule TodoWeb.Router do
  use TodoWeb, :router

  pipeline :auth do
    plug Todo.Accounts.Pipeline
  end

  pipeline :auth_required do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :dashboard do
    plug :put_layout, {TodoWeb.LayoutView, "dashboard.html"}
    plug TodoWeb.Plugs.AssignUser
  end

  scope "/", TodoWeb do
    pipe_through [:browser, :auth]

    get "/", HomeController, :index

    get "/login", SessionController, :new
    resources "/users", UserController, only: [:new, :create]
    post "/login", SessionController, :login
    post "/logout", SessionController, :logout
  end

  scope "/", TodoWeb do
    pipe_through [:browser, :auth, :auth_required, :dashboard]

    resources "/users", UserController, only: [:update, :edit]
    resources "/boards", BoardController, only: [:index, :new, :create, :show, :edit, :update]
    resources "/boards/:board_id/board-list", BoardListController, only: [:new, :create, :edit, :update]
  end

  # Other scopes may use custom stacks.
  # scope "/api", TodoWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TodoWeb.Telemetry
    end
  end
end
