defmodule HeadsUp.Queries.Incidents.FilterIncidents do
  @moduledoc """
  A query module for filtering raffles based on parameters.
  """
  use HeadsUp, :query

  alias HeadsUp.Incidents.Incident

  def call(params) do
    Incident
    |> with_status(params["status"])
    |> with_category(params["category"])
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

  defp sort(query, "category") do
    query |> join_category() |> order_by([_r, c], c.name)
  end

  defp sort(query, _), do: query

  defp with_category(query, id) when id in ["", nil], do: query

  defp with_category(query, id) do
    query |> join_category() |> where([_r, c], c.id == ^id)
  end

  defp join_category(query) when is_named_binding(query, :category) == true, do: query
  defp join_category(query), do: join(query, :inner, [r], c in assoc(r, :category))
end
