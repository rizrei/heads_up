defmodule HeadsUpWeb.IncidentComponents do
  use HeadsUpWeb, :live_component

  alias HeadsUp.Incidents.Incident

  import HeadsUpWeb.BadgeComponents

  attr :incident, Incident, required: true
  attr :response_count, :integer, required: true

  def incident(assigns) do
    ~H"""
    <div class="incident">
      <img src={@incident.image_path} />
      <section>
        <.badge status={@incident.status} />

        <header>
          <div>
            <h2>{@incident.name}</h2>
            <h3 :if={@incident.category}>{@incident.category.name}</h3>
          </div>
          <div class="priority">{@incident.priority}</div>
        </header>
        <div class="totals">
          {@response_count} Responses
        </div>
        <div class="description">
          {@incident.description}
        </div>
      </section>
    </div>
    """
  end

  def urgent_incidents(assigns) do
    ~H"""
    <section>
      <h4>Urgent Incidents</h4>
      <.async_result :let={result} assign={@incidents}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div class="failed">{reason}</div>
        </:failed>

        <ul :for={incident <- result} class="incidents">
          <li>
            <.link navigate={~p"/incidents/#{incident}"}>
              <img src={incident.image_path} />
              {incident.name}
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end

  def incident_watchers(assigns) do
    ~H"""
    <section>
      <h4>Onlookers</h4>
      <ul class="presences" id="incident-watchers" phx-update="stream">
        <li :for={{dom_id, %{id: name, metas: metas}} <- @incident_watchers} id={dom_id}>
          <.icon name="hero-user-circle-solid" class="w-5 h-5" />
          {name} ({length(metas)})
        </li>
      </ul>
    </section>
    """
  end
end
