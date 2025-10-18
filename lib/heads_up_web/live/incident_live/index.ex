defmodule HeadsUpWeb.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  import HeadsUpWeb.BadgeComponents
  import HeadsUpWeb.HeadlineComponents

  def mount(_params, _session, socket) do
    socket =
      assign(socket, incidents: HeadsUp.Incidents.list_incidents())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="incident-index">
        <.headline>
          <.icon name="hero-trophy-mini" /> 25 Incidents Resolved This Month!
          <:tagline :let={emoji}>Thanks for pitching in. {emoji}</:tagline>
        </.headline>
        <div class="incidents">
          <.incident_card :for={incident <- @incidents} incident={incident} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :incident, HeadsUp.Incidents.Incident, required: true

  def incident_card(assigns) do
    ~H"""
    <.link navigate={~p"/incidents/#{@incident}"}>
      <div class="card">
        <img src={@incident.image_path} />
        <h2>{@incident.name}</h2>
        <div class="details">
          <.badge status={@incident.status} />
          <div class="priority">
            {@incident.priority}
          </div>
        </div>
      </div>
    </.link>
    """
  end
end
