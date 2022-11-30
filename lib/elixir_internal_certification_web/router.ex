defmodule ElixirInternalCertificationWeb.Router do
  use ElixirInternalCertificationWeb, :router

  import ElixirInternalCertificationWeb.UserAuth

  alias ElixirInternalCertificationWeb.RouterHelper

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ElixirInternalCertificationWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # coveralls-ignore-start
  pipeline :api do
    plug :accepts, ["json"]
  end

  # coveralls-ignore-stop

  forward RouterHelper.health_path(), ElixirInternalCertificationWeb.HealthPlug

  scope "/", ElixirInternalCertificationWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", UploadLive, :index

    live "/keywords", KeywordLive.Index, :index
    live "/keywords/new", KeywordLive.Index, :new
    live "/keywords/:id/edit", KeywordLive.Index, :edit

    live "/keywords/:id", KeywordLive.Show, :show
    live "/keywords/:id/show/edit", KeywordLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirInternalCertificationWeb do
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

      # coveralls-ignore-start
      live_dashboard "/dashboard", metrics: ElixirInternalCertificationWeb.Telemetry
      # coveralls-ignore-stop
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ElixirInternalCertificationWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ElixirInternalCertificationWeb do
    pipe_through [:browser, :require_authenticated_user]
  end

  scope "/", ElixirInternalCertificationWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
