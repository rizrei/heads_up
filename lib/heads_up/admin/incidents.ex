defmodule HeadsUp.Admin.Incidents do
  use HeadsUp, :query
  alias HeadsUp.Incidents.Incident

  def list_incidents do
    Incident
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
