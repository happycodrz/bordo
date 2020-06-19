defmodule BordoWeb.Router do
  use BordoWeb, :router
  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router
  import BordoWeb.Plug.Session, only: [assign_current_admin: 2, assign_current_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :react do
    plug :put_root_layout, {BordoWeb.LayoutView, :react_root}
    plug :assign_current_user
  end

  pipeline :unauthenticated do
    plug :put_root_layout, {BordoWeb.LayoutView, :unauthenticated_root}
    plug Guardian.Plug.EnsureNotAuthenticated
  end

  pipeline :admin do
    plug :put_root_layout, {BordoWeb.LayoutView, :root_admin}
    plug :assign_current_admin
    plug Guardian.Permissions.Plug, ensure: %{admin: ["admin:all"]}
  end

  pipeline :onboarding_layout do
    plug :put_root_layout, {BordoWeb.LayoutView, :onboarding}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :private do
    plug Auth.Guardian.SessionPipeline
  end

  # Pipeline for private apis, requires Authorisation header with Bearer token
  pipeline :private_api do
    plug Auth.Guardian.ApiPipeline
  end

  get "/healthy-otter", BordoWeb.HealthzController, :index

  scope "/admin", BordoWeb.Admin, as: :admin do
    pipe_through [:browser, :private, :admin]
    live_dashboard "/dashboard", metrics: Bordo.Telemetry

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
    get "/logout", LogoutController, :index
  end

  scope "/", BordoWeb do
    pipe_through [:browser, :onboarding_layout, :private]
    live "/onboarding", OnboardingLive.Index
  end

  scope "/", BordoWeb do
    pipe_through [:api, :private_api]

    resources "/brands", BrandController do
      resources "/channels", Brands.ChannelController
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
    end

    get "/profile", ProfileController, :show
    resources "/teams", TeamController
  end

  # This must be defined last as a catchall /*path so react-routing will work
  scope "/", BordoWeb do
    pipe_through [:browser, :private, :onboarding_layout]

    scope "/oauth", Oauth do
      scope "/linkedin", LinkedInLive do
        live "/", Index
      end
    end
  end

  scope "/", BordoWeb do
    pipe_through [:browser, :private, :react]

    scope "/providers" do
      get "/twitter/callback", Providers.TwitterController, :callback
    end

    scope "/:brand_slug" do
      live "/launchpad", LaunchpadLive
      live "/schedule", ScheduleLive
      live "/media", MediaLive
      live "/settings", SettingsLive
    end

    live "/*path", OnboardingLive.Index
  end
end
