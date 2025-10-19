defmodule HeadsUpWeb.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  import HeadsUpWeb.BadgeComponents
  import HeadsUpWeb.HeadlineComponents

  alias HeadsUp.Incidents

  def mount(_params, _session, socket) do
    socket =
      stream(socket, :incidents, Incidents.filter_incidents())

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
        <div class="incidents" id="incidents" phx-update="stream">
          <.incident_card
            :for={{dom_id, incident} <- @streams.incidents}
            incident={incident}
            id={dom_id}
          />
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :incident, HeadsUp.Incidents.Incident, required: true
  attr :id, :string, required: true

  def incident_card(assigns) do
    ~H"""
    <.link navigate={~p"/incidents/#{@incident}"} id={@id}>
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
