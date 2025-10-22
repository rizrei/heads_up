defmodule HeadsUpWeb.Api.IncidentJSON do
  alias HeadsUp.Incidents.Incident

  def index(%{incidents: incidents}) do
    %{
      incidents: incidents |> Enum.map(&incident_attrs/1)
    }
  end

  def show(%{incident: incident}) do
    %{
      incident: incident_attrs(incident)
    }
  end

  @incident_attributes [:id, :name, :description, :priority, :status, :image_path, :category_id]
  defp incident_attrs(%Incident{} = incident) do
    incident
    |> Map.take(@incident_attributes)
  end
end
