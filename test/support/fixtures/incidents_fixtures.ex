defmodule HeadsUp.IncidentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HeadsUp.Responses` context.
  """

  @doc """
  Generate a response.
  """
  def incident_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "name",
        description: "description"
      })

    {:ok, response} = HeadsUp.Incidents.create_incident(attrs)
    response
  end
end
