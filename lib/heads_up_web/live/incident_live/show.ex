defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents
  alias HeadsUp.Responses
  alias HeadsUp.Responses.Response
  alias Phoenix.LiveView.AsyncResult

  import HeadsUpWeb.BadgeComponents

  on_mount {HeadsUpWeb.UserAuth, :mount_current_scope}

  def mount(%{"id" => id}, _session, socket) do
    incident = Incidents.get_incident_with_category!(id)

    socket =
      socket
      |> assign(:incident, incident)
      |> assign(:form, response_form(socket.assigns))
      |> assign(:page_title, incident.name)
      |> assign(:urgent_incidents, AsyncResult.loading())
      |> start_async(:urgent_incidents_task, fn -> Incidents.urgent_incidents(incident) end)

    {:ok, socket}
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
              <div>
                <h2>{@incident.name}</h2>
                <h3 :if={@incident.category}>{@incident.category.name}</h3>
              </div>
              <div class="priority">{@incident.priority}</div>
            </header>
            <div class="description">
              {@incident.description}
            </div>
          </section>
        </div>
        <div class="activity">
          <div class="left">
            <%= if @current_scope do %>
              <.form for={@form} id="response-form" phx-change="validate" phx-submit="save">
                <.input
                  field={@form[:status]}
                  type="select"
                  prompt="Choose a status"
                  options={[:enroute, :arrived, :departed]}
                />

                <.input
                  field={@form[:note]}
                  type="textarea"
                  placeholder="Note..."
                  autofocus
                />

                <.button>Post</.button>
              </.form>
            <% else %>
              <.button navigate={~p"/users/log-in"}>
                Log In To Get A response
              </.button>
            <% end %>
          </div>
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

  def handle_event("validate", %{"response" => response_params}, socket) do
    form =
      socket.assigns.current_scope
      |> Responses.change_response(%Response{}, response_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"response" => response_params}, socket) do
    case create_response(socket.assigns, response_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(form: response_form(socket.assigns))
         |> put_flash(:info, "Response created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def response_form(%{current_scope: scope}) do
    Responses.change_response(scope, %Response{}) |> to_form()
  end

  def create_response(%{incident: incident, current_scope: scope}, params) do
    Responses.create_response(scope, params |> Map.merge(%{"incident_id" => incident.id}))
  end
end
