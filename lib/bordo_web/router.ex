defmodule BordoWeb.Router do
  use BordoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BordoWeb do
    pipe_through :api
  end
end
