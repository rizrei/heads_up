defmodule HeadsUp.Incidents do
  use HeadsUp, :query

  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Queries.Incidents.FilterIncidents

  def list_incidents do
    Repo.all(Incident)
  end

  def filter_incidents_with_category(filters \\ %{}) do
    FilterIncidents.call(filters) |> Repo.preload(:category)
  end

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

  def get_incident_with_category!(id) do
    id |> get_incident!() |> Repo.preload(:category)
  end

  def urgent_incidents(incident) do
    Process.sleep(:timer.seconds(2))

    Incident
    |> where([i], i.id != ^incident.id)
    |> order_by(:priority)
    |> limit(3)
    |> Repo.all()
  end
end
