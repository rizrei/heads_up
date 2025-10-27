defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUp, :pub_sub
  use HeadsUpWeb, :live_view

  alias HeadsUp.Repo
  alias HeadsUp.Incidents
  alias HeadsUp.Responses
  alias HeadsUp.Responses.Response
  alias Phoenix.LiveView.AsyncResult
  alias HeadsUpWeb.Presence

  import HeadsUpWeb.ResponseComponent
  import HeadsUpWeb.HeadlineComponents
  import HeadsUpWeb.IncidentComponents

  on_mount {HeadsUpWeb.UserAuth, :mount_current_scope}

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      subscribe("incident:#{id}")

      if socket.assigns.current_scope do
        subscribe("updates:incident_watchers:#{id}")
        Presence.track_user("incident_watchers:#{id}", socket.assigns.current_scope.user)
      end
    end

    incident =
      id |> Incidents.get_incident!() |> preload_incident_references()

    responses = Responses.list_responses_by_incident(incident)

    socket =
      socket
      |> stream(:responses, responses)
      |> stream(:incident_watchers_list, Presence.list_users("incident_watchers:#{id}"))
      |> assign(:incident, incident)
      |> assign(:response_count, Enum.count(responses))
      |> assign(:form, Responses.change_response(%Response{}) |> to_form())
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
      %Response{}
      |> Responses.change_response(response_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"response" => response_params}, socket) do
    case create_response(socket.assigns, response_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:form, Responses.change_response(%Response{}) |> to_form())
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
     |> assign(:incident, incident |> preload_incident_references())}
  end

  def handle_info({:user_joined, presence}, socket) do
    {:noreply, stream_insert(socket, :incident_watchers_list, presence)}
  end

  def handle_info({:user_left, presence}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :incident_watchers_list, presence)}
    else
      {:noreply, stream_insert(socket, :incident_watchers_list, presence)}
    end
  end

  def create_response(%{incident: incident, current_scope: scope}, params) do
    Responses.create_response(scope, params |> Map.merge(%{"incident_id" => incident.id}))
  end

  defp preload_incident_references(incident) do
    Repo.preload(incident, [:category, heroic_response: :user])
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="incident-show">
        <.headline :if={@incident.heroic_response}>
          <.icon name="hero-sparkles-solid" /> Heroic Responder: {@incident.heroic_response.user.name}
          <:tagline>
            {@incident.heroic_response.note}
          </:tagline>
        </.headline>

        <.incident incident={@incident} response_count={@response_count} />

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
            <.incident_watchers
              :if={@current_scope}
              incident_watchers={@streams.incident_watchers_list}
            />
          </div>
        </div>

        <.back navigate={~p"/incidents"}>All Incidents</.back>
      </div>
    </Layouts.app>
    """
  end
end
