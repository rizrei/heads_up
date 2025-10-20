defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents
  alias Phoenix.LiveView.AsyncResult

  import HeadsUpWeb.BadgeComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    incident = Incidents.get_incident!(id)

    socket =
      socket
      |> assign(:incident, incident)
      |> assign(:page_title, incident.name)
      |> assign(:urgent_incidents, AsyncResult.loading())
      |> start_async(:urgent_incidents_task, fn -> Incidents.urgent_incidents(incident) end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="incident-show">
        <div class="incident">
          <img src={@incident.image_path} />
          <section>
            <.badge status={@incident.status} />

            <header>
              <h2>{@incident.name}</h2>
              <div class="priority">{@incident.priority}</div>
            </header>
            <div class="description">
              {@incident.description}
            </div>
          </section>
        </div>
        <div class="activity">
          <div class="left"></div>
          <div class="right">
            <.urgent_incidents incidents={@urgent_incidents} />
          </div>
        </div>

        <.back navigate={~p"/incidents"}>All Incidents</.back>
      </div>
    </Layouts.app>
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

  def handle_async(:urgent_incidents_task, {:ok, raffles}, socket) do
    # do anything extra here

    result = AsyncResult.ok(socket.assigns.urgent_incidents, raffles)

    {:noreply, assign(socket, :urgent_incidents, result)}
  end

  def handle_async(:urgent_incidents_task, {:exit, reason}, socket) do
    # do anything extra

    result = AsyncResult.failed(socket.assigns.urgent_incidents, {:exit, reason})

    {:noreply, assign(socket, :urgent_incidents, result)}
  end
end
