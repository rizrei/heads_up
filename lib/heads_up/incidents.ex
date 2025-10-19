defmodule HeadsUp.Incidents do
  alias HeadsUp.Repo
  alias HeadsUp.Incidents.Incident

  def list_incidents do
    Repo.all(Incident)
  end

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

  def urgent_incidents(incident) do
    list_incidents() |> List.delete(incident)
  end
end
