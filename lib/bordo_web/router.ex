defmodule BordoWeb.Router do
  use BordoWeb, :router
  import Bordo.Brands.Pipeline, only: [brand_resource: 2]

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
    resources "/users", UserController
    resources "/user-brands", BrandUserController, only: [:create]
  end
end
