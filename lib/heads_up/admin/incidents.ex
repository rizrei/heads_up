defmodule HeadsUp.Admin.Incidents do
  use HeadsUp, :query

  alias HeadsUp.Incidents.Incident

  def list_incidents do
    Incident
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_incident!(id) do
    Incident |> Repo.get(id)
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
    incident
    |> Incident.changeset(attrs)
    |> Repo.update()
  end

  def delete_incident(%Incident{} = incident) do
    Repo.delete(incident)
  end
end
