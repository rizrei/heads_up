defmodule HeadsUpWeb.Api.IncidentController do
  use HeadsUpWeb, :controller

  alias HeadsUp.Admin.Incidents

  action_fallback HeadsUpWeb.FallbackController

  def index(conn, %{"category_id" => category_id}) do
    conn
    |> assign(:incidents, Incidents.get_incidents_by_category_id(category_id))
    |> render(:index)
  end

  def index(conn, _params) do
    conn
    |> assign(:incidents, Incidents.list_incidents())
    |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, incident} <- Incidents.fetch_incident(id) do
      conn
      |> assign(:incident, incident)
      |> render(:show)
    end
  end

  def create(conn, %{"incident" => incident_params}) do
    with {:ok, incident} <- Incidents.create_incident(incident_params) do
      conn
      |> assign(:incident, incident)
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/incidents/#{incident}")
      |> render(:show)
    end
  end
end
