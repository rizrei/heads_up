defmodule HeadsUp.Admin.Incidents.HeroicResponses do
  use HeadsUp, :query

  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Responses.Response

  import HeadsUp.Admin.Incidents, only: [update_incident: 2, fetch_incident: 1]

  @spec draw_heroic_response(integer()) ::
          {:ok, %{response: Response.t(), incident: Incident.t()}} | {:error, String.t()}
  def draw_heroic_response(incident_id) do
    with {:ok, incident} <- fetch_incident(incident_id),
         {:ok, _} <- validate_incident_status(incident),
         {:ok, response} <- draw_random_response(incident),
         {:ok, updated_incident} <- update_incident(incident, %{heroic_response_id: response.id}) do
      {:ok, %{response: response, incident: updated_incident}}
    else
      {:error, :not_found} -> {:error, "Incident not found!"}
      {:error, %Ecto.Changeset{}} -> {:error, "Failed to update record!"}
      {:error, msg} -> {:error, msg}
    end
  end

  defp validate_incident_status(%Incident{status: :resolved} = incident), do: {:ok, incident}

  defp validate_incident_status(%Incident{}) do
    {:error, "Incident must be resolved to draw a heroic response!"}
  end

  defp draw_random_response(incident) do
    incident
    |> Ecto.assoc(:responses)
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
    |> case do
      nil -> {:error, "No responses to draw!"}
      response -> {:ok, response}
    end
  end
end
