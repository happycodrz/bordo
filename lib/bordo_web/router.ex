defmodule BordoWeb.Router do
  use BordoWeb, :router
  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router
  import BordoWeb.Plug.Session, only: [redirect_authorized: 2, assign_current_admin: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Auth.Guardian.SessionPipeline
  end

  pipeline :react do
    plug :put_layout, {BordoWeb.LayoutView, :react_root}
  end

  pipeline :unauthenticated do
    plug :put_root_layout, {BordoWeb.LayoutView, :unauthenticated_root}
    plug :redirect_authorized
  end

  pipeline :admin do
    plug :put_root_layout, {BordoWeb.LayoutView, :root}
    plug :assign_current_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Pipeline for private apis, requires Authorisation header with Bearer token
  pipeline :private_api do
    plug Auth.Guardian.ApiPipeline
  end

  scope "/admin", BordoWeb.Admin, as: :admin do
    pipe_through [:browser, :admin]
    live_dashboard "/dashboard", metrics: Bordo.Telemetry

    get "/logout", AuthController, :index

    scope "/posts", PostsLive do
      live "/", Index
    end

    scope "/users", UsersLive do
      live "/", Index
      live "/:id/edit", Edit
      live "/new", New
    end

    scope "/teams", TeamsLive do
      live "/", Index
      live "/:id/edit", Edit
      live "/new", New
    end
  end

  scope "/auth", BordoWeb do
    pipe_through :api

    post "/sign-in", AuthController, :create
  end

  scope "/", BordoWeb do
    post("/hooks", WebhookController, :hook)
  end

  scope "/", BordoWeb do
    pipe_through [:browser, :unauthenticated]
    get "/login", LoginController, :index
    post "/login", LoginController, :login
  end

  scope "/", BordoWeb do
    pipe_through [:api, :private_api]

    resources "/brands", BrandController do
      resources "/channels", Brands.ChannelController, except: [:update]
      resources "/media", Brands.MediaController
      resources "/posts", Brands.PostController
      resources "/users", Brands.UserController
    end

    resources "/brand-users", BrandUserController, only: [:create]

    scope "/providers" do
      get "/linkedin/auth", Providers.LinkedinController, :auth
      get "/linkedin/callback", Providers.LinkedinController, :callback
      get "/facebook/auth", Providers.FacebookController, :auth
      get "/facebook/callback", Providers.FacebookController, :callback
      get "/twitter/auth", Providers.TwitterController, :auth
      get "/twitter/callback", Providers.TwitterController, :callback
    end

    get "/profile", ProfileController, :show
    resources "/teams", TeamController
  end

  # This must be defined last as a catchall /*path so react-routing will work
  scope "/", BordoWeb do
    pipe_through [:browser, :react]

    get "/", ReactController, :index
    get "/*path", ReactController, :index
  end
end
