defmodule BordoWeb.Router do
  use BordoWeb, :router
  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router

  import BordoWeb.Plug.Session,
    only: [redirect_unauthorized: 2, validate_session: 2, redirect_authorized: 2]

  import Bordo.Brands.Pipeline, only: [brand_resource: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BordoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :unauthenticated do
    plug :put_root_layout, {BordoWeb.LayoutView, :unauthenticated_root}
    plug :redirect_authorized
  end

  pipeline :admin_session do
    plug :browser
    plug :validate_session
  end

  pipeline :restricted do
    plug :redirect_unauthorized
  end

  pipeline :public do
    plug :accepts, ["json"]
  end

  # Pipeline for private apis, requires Authorisation header with Bearer token
  pipeline :private do
    plug :accepts, ["json"]

    plug Auth.Guardian.Pipeline
  end

  pipeline :brands do
    plug :brand_resource
  end

  scope "/admin", BordoWeb.Admin, as: :admin do
    pipe_through [:admin_session, :unauthenticated]

    live "/login", AuthLive.Login
  end

  scope "/admin", BordoWeb.Admin, as: :admin do
    pipe_through [:admin_session, :restricted]
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
    pipe_through :public

    post "/sign-in", AuthController, :create
  end

  scope "/", BordoWeb do
    pipe_through :private

    resources "/brands", BrandController do
      pipe_through :brands

      resources "/channels", Brands.ChannelController, except: [:update]
      resources "/media", Brands.MediaController
      resources "/posts", Brands.PostController
      resources "/users", Brands.UserController
    end

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
    resources "/user-brands", BrandUserController, only: [:create]
  end
end
