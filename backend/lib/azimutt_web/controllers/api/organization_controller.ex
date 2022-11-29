defmodule AzimuttWeb.Api.OrganizationController do
  use AzimuttWeb, :controller
  use PhoenixSwagger
  alias Azimutt.Organizations
  alias AzimuttWeb.Utils.CtxParams
  action_fallback AzimuttWeb.Api.FallbackController

  def index(conn, params) do
    current_user = conn.assigns.current_user
    ctx = CtxParams.from_params(params)
    organizations = Organizations.list_organizations(current_user)
    conn |> render("index.json", organizations: organizations, ctx: ctx)
  end
end