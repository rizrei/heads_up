defmodule HeadsUp.ResponsesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HeadsUp.Responses` context.
  """

  @doc """
  Generate a response.
  """
  def response_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        note: "some note",
        status: :enroute
      })

    {:ok, response} = HeadsUp.Responses.create_response(scope, attrs)
    response
  end
end
