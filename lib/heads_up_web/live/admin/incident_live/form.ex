defmodule HeadsUpWeb.Admin.IncidentLive.Form do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin.Categories
  alias HeadsUp.Admin.Incidents
  alias HeadsUp.Incidents.Incident

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(:category_options, Categories.categories_names_and_ids())
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Incident")
    |> assign(:form, %Incident{} |> Incidents.change_incident() |> to_form())
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    incident = Incidents.get_incident!(id)

    socket
    |> assign(:page_title, "Edit Incident")
    |> assign(:incident, incident)
    |> assign(:form, Incidents.change_incident(incident) |> to_form())
  end

  def handle_event("validate", %{"incident" => incident_params}, socket) do
    form = %Incident{} |> Incidents.change_incident(incident_params) |> to_form(action: :validate)

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"incident" => incident_params}, socket) do
    {:noreply, save_incident(socket, socket.assigns.live_action, incident_params)}
  end

  defp save_incident(socket, :new, params) do
    case Incidents.create_incident(params) do
      {:ok, _raffle} ->
        socket
        |> put_flash(:info, "Incident created successfully!")
        |> push_navigate(to: ~p"/admin/incidents")

      {:error, %Ecto.Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
    end
  end

  defp save_incident(socket, :edit, params) do
    case Incidents.update_incident(socket.assigns.incident, params) do
      {:ok, _raffle} ->
        socket
        |> put_flash(:info, "Incident updated successfully!")
        |> push_navigate(to: ~p"/admin/incidents")

      {:error, %Ecto.Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
    end
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
        <.input
          field={@form[:category_id]}
          type="select"
          label="Category"
          prompt="Choose a Category"
          options={@category_options}
        />

        <.input field={@form[:image_path]} label="Image Path" required="true" />

        <.button phx-disable-with="Saving...">Save incident</.button>
      </.form>

      <.button navigate={~p"/admin/incidents"}>Back</.button>
    </Layouts.app>
    """
  end
end
