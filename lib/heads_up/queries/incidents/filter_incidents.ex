defmodule HeadsUp.Queries.Incidents.FilterIncidents do
  @moduledoc """
  A query module for filtering raffles based on parameters.
  """
  use HeadsUp, :query

  alias HeadsUp.Incidents.Incident

  def call(params) do
    Incident
    |> with_status(params["status"])
    |> search_by(params["q"])
    |> sort(params["sort_by"])
    |> Repo.all()
  end

  defp with_status(query, status) when status in ~w(pending resolved canceled),
    do: where(query, status: ^status)

  defp with_status(query, _), do: query

  defp search_by(query, ""), do: query
  defp search_by(query, q) when is_binary(q), do: where(query, [i], ilike(i.name, ^"%#{q}%"))
  defp search_by(query, _), do: query

  defp sort(query, "name"), do: order_by(query, :name)
  defp sort(query, "priority_desc"), do: order_by(query, desc: :priority)
  defp sort(query, "priority_asc"), do: order_by(query, :priority)
  defp sort(query, _), do: query
end
