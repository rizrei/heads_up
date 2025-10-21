defmodule HeadsUpWeb.Admin.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin.Incidents
  import HeadsUpWeb.BadgeComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Incidents")
      |> stream(:incidents, Incidents.list_incidents())

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-index">
        <.header>
          {@page_title}
          <:actions>
            <.button navigate={~p"/admin/incidents/new"}>New Incident</.button>
          </:actions>
        </.header>

        <.table id="incidents" rows={@streams.incidents}>
          <:col :let={{_dom_id, incident}} label="Name">
            <.link navigate={~p"/incidents/#{incident}"}>
              {incident.name}
            </.link>
          </:col>
          <:col :let={{_dom_id, incident}} label="Status">
            <.badge status={incident.status} />
          </:col>
          <:col :let={{_dom_id, incident}} label="Priority">
            {incident.priority}
          </:col>

          <:action :let={{_dom_id, incident}}>
            <.link navigate={~p"/admin/incidents/#{incident}/edit"}>Edit</.link>
          </:action>
        </.table>
      </div>
    </Layouts.app>
    """
  end
end
