defmodule BordoWeb.Router do
  use BordoWeb, :router

  pipeline :public do
    plug :accepts, ["json"]
  end

  # Pipeline for private apis, requires Authorisation header with Bearer token
  pipeline :private do
    plug :accepts, ["json"]

    plug Auth.Guardian.Pipeline
  end

  scope "/auth", BordoWeb do
    pipe_through :public

    post "/sign-in", AuthController, :create
  end

  scope "/", BordoWeb do
    pipe_through :private

    resources "/brands", BrandController do
      resources "/channels", Brands.ChannelController
      resources "/posts", Brands.PostController
      resources "/users", Brands.UserController
    end

    scope "/providers" do
      get "/twitter/auth", Providers.TwitterController, :auth
      get "/twitter/callback", Providers.TwitterController, :callback
    end

    resources "/images", ImageController
    resources "/teams", TeamController
    resources "/users", UserController
    resources "/user-brands", UserBrandController, only: [:create]

    scope "/uploads", Uploads do
      resources "/aws", AwsController, only: [:create]
    end
  end
end
