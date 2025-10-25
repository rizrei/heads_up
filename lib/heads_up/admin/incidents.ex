defmodule HeadsUp.Admin.Incidents do
  use HeadsUp, :query
  use HeadsUp, :pub_sub

  alias HeadsUp.Incidents.Incident

  def list_incidents do
    Incident
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_incident!(id), do: Repo.get(Incident, id)

  def fetch_incident(id), do: fetch(id, &get_incident!/1)

  def get_incidents_by_category_id(category_id) do
    Incident
    |> where([i], i.category_id == ^category_id)
    |> Repo.all()
  end

  def create_incident(attrs) do
    %Incident{}
    |> Incident.changeset(attrs)
    |> Repo.insert()
  end

  def change_incident(%Incident{} = incident, attrs \\ %{}) do
    Incident.changeset(incident, attrs)
  end

  def update_incident(%Incident{} = incident, attrs) do
    with {:ok, incident} <-
           incident
           |> Incident.changeset(attrs)
           |> Repo.update() do
      broadcast("incident:#{incident.id}", {:incident_updated, incident})
      {:ok, incident}
    end
  end

  def delete_incident(%Incident{} = incident) do
    Repo.delete(incident)
  end

  defp fetch(attr, f) do
    f.(attr) |> then(&{:ok, &1})
  rescue
    Ecto.NoResultsError -> {:error, :not_found}
  end
end
