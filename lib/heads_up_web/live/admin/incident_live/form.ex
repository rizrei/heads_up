defmodule HeadsUpWeb.Admin.IncidentLive.Form do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin.Categories
  alias HeadsUp.Admin.Incidents
  alias HeadsUp.Incidents.Incident

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:category_options, Categories.categories_names_and_ids())
      |> allow_upload(:image,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 1,
        max_file_size: 10_000_000
      )

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  def handle_event("validate", %{"incident" => incident_params}, socket) do
    form = %Incident{} |> Incidents.change_incident(incident_params) |> to_form(action: :validate)

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"incident" => incident_params}, socket) do
    uploads_dir = Application.app_dir(:heads_up, "priv/static/uploads")
    File.mkdir_p!(uploads_dir)

    uploaded_files =
      consume_uploaded_entries(socket, :image, fn meta, entry ->
        dest = Path.join(uploads_dir, "#{entry.uuid}-#{entry.client_name}")
        File.cp!(meta.path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    incident_params =
      case uploaded_files do
        [path] -> Map.put(incident_params, "image_path", path)
        [] -> incident_params
      end

    {:noreply, save_incident(socket, socket.assigns.live_action, incident_params)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
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

        <div class="thumbnail">
          <.input field={@form[:image_path]} label="Image Path" />

          <img src={@incident.image_path} />
        </div>

        <.label>
          Add {@uploads.image.max_entries} image
          (max {trunc(@uploads.image.max_file_size / 1_000_000)} MB)
        </.label>

        <div class="drop" phx-drop-target={@uploads.image.ref}>
          <.live_file_input upload={@uploads.image} />
          <span>or drag and drop here</span>
        </div>
        <div :for={entry <- @uploads.image.entries} class="entry">
          <.live_img_preview entry={entry} />

          <div class="progress">
            <div class="value">
              {entry.progress}%
            </div>
            <div class="bar">
              <span style={"width: #{entry.progress}%"}></span>
            </div>
            <p :for={err <- upload_errors(@uploads.image, entry)}>
              {error_to_string(err)}
            </p>
          </div>

          <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
            &times;
          </button>
        </div>

        <.button phx-disable-with="Saving...">Save incident</.button>
      </.form>

      <.button navigate={~p"/admin/incidents"}>Back</.button>
    </Layouts.app>
    """
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
