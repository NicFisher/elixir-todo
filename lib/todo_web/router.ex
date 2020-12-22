defmodule TodoWeb.Router do
  use TodoWeb, :router
  import Phoenix.LiveView.Router

  pipeline :auth do
    plug Todo.Accounts.Pipeline
  end

  pipeline :auth_required do
    plug Guardian.Plug.EnsureAuthenticated
    plug TodoWeb.Plugs.AssignUser
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :dashboard do
    plug :put_layout, {TodoWeb.LayoutView, "dashboard.html"}
  end

  pipeline :live_view do
    plug :put_root_layout, {TodoWeb.LayoutView, :dashboard}
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
    resources "/boards", BoardController, only: [:index, :new, :create, :edit, :update]

    resources "/shared-boards/boards", SharedBoard.BoardController,
      only: [:index, :edit, :update],
      name: :shared_board

    resources "/shared-boards/boards/:shared_board_id/list", SharedBoard.ListController,
      only: [:new, :create, :edit, :update],
      name: :shared_board_list

    resources "/boards/:board_id/list", ListController, only: [:new, :create, :edit, :update]

    resources "/share-board", ShareBoardTokenController, only: [:new, :create, :index]
    get "/share-board/activate", ShareBoardTokenController, :activate
  end

  scope "/boards", TodoWeb do
    pipe_through [:browser, :auth, :auth_required, :live_view]

    live "/:id", BoardLiveView
  end

  scope "/shared-boards/boards", TodoWeb do
    pipe_through [:browser, :auth, :auth_required, :live_view]

    live "/:shared_board_id", BoardLiveView
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
