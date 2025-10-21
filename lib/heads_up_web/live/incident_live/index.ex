defmodule HeadsUpWeb.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  import HeadsUpWeb.BadgeComponents
  import HeadsUpWeb.HeadlineComponents

  alias HeadsUp.Incidents

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="incident-index">
        <.headline :if={false}>
          <.icon name="hero-trophy-mini" /> 25 Incidents Resolved This Month!
          <:tagline :let={emoji}>Thanks for pitching in. {emoji}</:tagline>
        </.headline>

        <.filter_form form={@form} />
        <div class="incidents" id="incidents" phx-update="stream">
          <div id="empty" class="no-results only:block hidden">
            No incidents found. Try changing your filters.
          </div>
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

  attr :form, :map, required: true

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="filter">
      <.input
        field={@form["q"]}
        type="search"
        placeholder="Search..."
        autocomplete="off"
        phx-debounce={500}
      />
      <.input
        field={@form["status"]}
        type="select"
        options={[:pending, :resolved, :canceled]}
        prompt="Status"
      />

      <.input
        field={@form["sort_by"]}
        type="select"
        options={[
          Name: "name",
          "Priority: High to Low": "priority_desc",
          "Priority: Low to High": "priority_asc"
        ]}
        prompt="Sort"
      />

      <.button patch={~p"/incidents"}>Reset</.button>
    </.form>
    """
  end

  attr :incident, HeadsUp.Incidents.Incident, required: true
  attr :id, :string, required: true

  def incident_card(assigns) do
    ~H"""
    <.link navigate={~p"/incidents/#{@incident}"} id={@id}>
      <div class="card">
        <div :if={@incident.category} class="category">
          <h3>{@incident.category.name}</h3>
        </div>

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

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> stream(:incidents, Incidents.filter_incidents_with_category(params), reset: true)
      |> assign(:form, to_form(params))

    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    filtered_params =
      params
      |> Map.filter(fn {k, v} -> k in ~w(q status sort_by) and v not in [nil, ""] end)

    socket = push_patch(socket, to: ~p"/incidents?#{filtered_params}")

    {:noreply, socket}
  end
end
