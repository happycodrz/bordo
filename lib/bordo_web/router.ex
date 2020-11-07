defmodule BordoWeb.Router do
  use BordoWeb, :router
  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router
  import BordoWeb.Plug.Session, only: [assign_current_admin: 2, verify_brand_access: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :webhooks do
    plug :accepts, ["json"]
    plug BordoWeb.WebhooksAuthPlug
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

  pipeline :private do
    plug :put_root_layout, {BordoWeb.LayoutView, :root}
    plug Auth.Guardian.SessionPipeline
    plug :verify_brand_access
  end

  get "/healthy-otter", BordoWeb.HealthzController, :index

  scope "/admin", BordoWeb.Admin, as: :admin do
    pipe_through [:browser, :private, :admin]
    live_dashboard "/dashboard", metrics: Bordo.Telemetry

    scope "/posts", PostsLive do
      live "/", Index
      live "/:post_id", Index
    end

    scope "/users", UsersLive do
      live "/", Index
      live "/new", New
      live "/:user_id", Index
    end

    scope "/teams", TeamsLive do
      live "/", Index
      live "/:id/edit", Edit
      live "/new", New
    end
  end

  scope "/", BordoWeb do
    pipe_through [:webhooks]
    post("/webhooks", WebhookController, :hook)
    get "/providers/zapier/check", Providers.ZapierController, :check

    resources "/webhooks/subscriptions", Webhooks.SubscriptionController,
      only: [:index, :create, :delete]
  end

  scope "/", BordoWeb do
    pipe_through [:browser, :unauthenticated]
    get "/login", LoginController, :index
    get "/signup", RegistrationController, :index
    get "/forgot-password", ForgotPasswordController, :index
    post "/forgot-password", ForgotPasswordController, :reset
    post "/login", LoginController, :login
    post "/signup", RegistrationController, :register
    get "/logout", LogoutController, :index
  end

  scope "/", BordoWeb do
    pipe_through [:browser, :onboarding_layout, :private]
    live "/", OnboardingLive.Index
    live "/onboarding", OnboardingLive.Index
  end

  scope "/", BordoWeb do
    pipe_through [:browser, :private, :onboarding_layout]

    scope "/oauth", Oauth do
      live "/facebook", FacebookLive.Index
      live "/linkedin", LinkedInLive.Index
    end
  end

  scope "/", BordoWeb do
    pipe_through [:browser, :private]

    scope "/providers" do
      get "/facebook/auth", Providers.FacebookController, :auth
      get "/facebook/reauth", Providers.FacebookController, :reauth
      get "/facebook/callback/reauth", Providers.FacebookController, :reauth_callback
      get "/google/auth", Providers.GoogleController, :auth
      get "/google/callback", Providers.GoogleController, :callback
      get "/twitter/auth", Providers.TwitterController, :auth
      get "/twitter/callback", Providers.TwitterController, :callback
      get "/linkedin/auth", Providers.LinkedinController, :auth
      get "/zapier/auth", Providers.ZapierController, :auth
    end

    scope "/:brand_slug" do
      live "/", BordoLive
      live "/launchpad", BordoLive, :launchpad
      live "/media", BordoLive, :media
      live "/posts/new", BordoLive, :new_post
      live "/schedule", BordoLive, :schedule
      live "/settings", BordoLive, :settings
      live "/team-settings", BordoLive, :team_settings
    end
  end
end
