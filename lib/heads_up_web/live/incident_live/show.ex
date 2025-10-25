defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUp, :pub_sub
  use HeadsUpWeb, :live_view

  alias HeadsUp.Repo
  alias HeadsUp.Incidents
  alias HeadsUp.Responses
  alias HeadsUp.Responses.Response
  alias Phoenix.LiveView.AsyncResult

  import HeadsUpWeb.BadgeComponents
  import HeadsUpWeb.ResponseComponent

  on_mount {HeadsUpWeb.UserAuth, :mount_current_scope}

  def mount(%{"id" => id}, _session, socket) do
    incident = Incidents.get_incident_with_category!(id)
    responses = Responses.list_responses_by_incident(incident)

    if connected?(socket), do: subscribe("incident:#{id}")

    socket =
      socket
      |> assign(:incident, incident)
      |> stream(:responses, responses)
      |> assign(:response_count, Enum.count(responses))
      |> assign(:form, response_form(socket.assigns))
      |> assign(:page_title, incident.name)
      |> assign(:urgent_incidents, AsyncResult.loading())
      |> start_async(:urgent_incidents_task, fn -> Incidents.urgent_incidents(incident) end)

    {:ok, socket}
  end

  def handle_async(:urgent_incidents_task, {:ok, incidents}, socket) do
    # do anything extra here

    result = AsyncResult.ok(socket.assigns.urgent_incidents, incidents)

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

  def handle_info({:response_created, %Response{} = response}, socket) do
    {:noreply,
     socket
     |> stream_insert(:responses, response |> Repo.preload(:user), at: 0)
     |> update(:response_count, &(&1 + 1))}
  end

  def handle_info({:incident_updated, incident}, socket) do
    {:noreply,
     socket
     |> assign(:incident, incident |> Repo.preload(:category))}
  end

  def response_form(%{current_scope: scope}) do
    Responses.change_response(scope, %Response{}) |> to_form()
  end

  def create_response(%{incident: incident, current_scope: scope}, params) do
    Responses.create_response(scope, params |> Map.merge(%{"incident_id" => incident.id}))
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
            <div class="totals">
              {@response_count} Responses
            </div>
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

          <div id="responses" phx-update="stream">
            <.response
              :for={{dom_id, response} <- @streams.responses}
              response={response}
              id={dom_id}
            />
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
end
