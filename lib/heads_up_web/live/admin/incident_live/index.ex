defmodule HeadsUpWeb.Admin.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin.Incidents
  alias HeadsUp.Admin.Incidents.HeroicResponses

  import HeadsUpWeb.BadgeComponents
  import HeadsUpWeb.JSComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Incidents")
      |> stream(:incidents, Incidents.list_incidents())

    {:ok, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    socket =
      case Incidents.get_incident!(id) |> Incidents.delete_incident() do
        {:ok, incident} ->
          socket
          |> put_flash(:info, "incident deleted successfully!")
          |> stream_delete(:incidents, incident)

        {:error, %Ecto.Changeset{}} ->
          socket
          |> put_flash(:error, "Something went wrong!")
      end

    {:noreply, socket}
  end

  def handle_event("draw-heroic-response", %{"id" => id}, socket) do
    socket =
      case HeroicResponses.draw_heroic_response(id) do
        {:ok, %{incident: incident}} ->
          socket
          |> put_flash(:info, "Heroic response drawn!")
          |> stream_insert(:incidents, incident)

        {:error, msg} ->
          socket
          |> put_flash(:error, msg)
      end

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

        <.table
          id="incidents"
          rows={@streams.incidents}
          row_click={fn {_, incidents} -> JS.navigate(~p"/incidents/#{incidents}") end}
        >
          <:col :let={{_dom_id, incident}} label="Name">
            <.link navigate={~p"/incidents/#{incident}"}>{incident.name}</.link>
          </:col>
          <:col :let={{_dom_id, incident}} label="Status">
            <.badge status={incident.status} />
          </:col>
          <:col :let={{_dom_id, incident}} label="Priority">{incident.priority}</:col>
          <:col :let={{_dom_id, incident}} label="Heroic Response ID">
            {incident.heroic_response_id}
          </:col>

          <:action :let={{_dom_id, incident}}>
            <.link navigate={~p"/admin/incidents/#{incident}/edit"}>Edit</.link>
          </:action>

          <:action :let={{dom_id, incident}}>
            <.link phx-click={delete_and_hide(dom_id, incident)} data-confirm="Are you shure?">
              <.icon name="hero-trash" class="h-4 w-4" />
            </.link>
          </:action>
          <:action :let={{_dom_id, incident}}>
            <.link phx-click="draw-heroic-response" phx-value-id={incident.id}>
              Draw Heroic Response
            </.link>
          </:action>
        </.table>
      </div>
    </Layouts.app>
    """
  end
end
