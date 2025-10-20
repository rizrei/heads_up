defmodule HeadsUpWeb.Admin.IncidentLive.Form do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin.Incidents
  alias HeadsUp.Incidents.Incident

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    socket =
      socket
      |> assign(:page_title, "New Incident")
      |> assign(:form, %Incident{} |> Incidents.change_incident() |> to_form())

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@page_title}</.header>

      <.form for={@form} id="incident-form" phx-submit="save" phx-change="validate">
        <.input field={@form[:name]} label="Name" />

        <.input
          field={@form[:description]}
          type="textarea"
          label="Description"
          required="true"
          phx-debounce="500"
        />

        <.input
          field={@form[:priority]}
          type="number"
          label="Priority"
          required="true"
          phx-debounce="500"
        />

        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a status"
          options={[:pending, :resolved, :canceled]}
          required="true"
        />

        <.input field={@form[:image_path]} label="Image Path" required="true" />

        <.button phx-disable-with="Saving...">Save incident</.button>
      </.form>

      <.button navigate={~p"/admin/incidents"}>Back</.button>
    </Layouts.app>
    """
  end

  def handle_event("validate", %{"incident" => incident_params}, socket) do
    form = %Incident{} |> Incidents.change_incident(incident_params) |> to_form(action: :validate)

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"incident" => incident_params}, socket) do
    socket =
      case Incidents.create_incident(incident_params) do
        {:ok, _raffle} ->
          socket
          |> put_flash(:info, "Incident created successfully!")
          |> push_navigate(to: ~p"/admin/incidents")

        {:error, %Ecto.Changeset{} = changeset} ->
          socket
          |> assign(:form, to_form(changeset))
      end

    {:noreply, socket}
  end
end
