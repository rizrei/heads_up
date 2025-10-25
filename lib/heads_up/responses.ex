defmodule HeadsUp.Responses do
  @moduledoc """
  The Responses context.
  """

  use HeadsUp, :query
  use HeadsUp, :pub_sub

  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Responses.Response
  alias HeadsUp.Accounts.Scope

  @doc """
  Returns the list of responses.

  ## Examples

      iex> list_responses(scope)
      [%Response{}, ...]

  """
  def list_responses(%Scope{} = scope) do
    Repo.all_by(Response, user_id: scope.user.id)
  end

  def list_responses_by_incident(%Incident{id: incident_id}) do
    Response
    |> order_by(desc: :inserted_at)
    |> Repo.all_by(incident_id: incident_id)
    |> Repo.preload([:user])
  end

  @doc """
  Gets a single response.

  Raises `Ecto.NoResultsError` if the Response does not exist.

  ## Examples

      iex> get_response!(scope, 123)
      %Response{}

      iex> get_response!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_response!(%Scope{} = scope, id) do
    Repo.get_by!(Response, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a response.

  ## Examples

      iex> create_response(scope, %{field: value})
      {:ok, %Response{}}

      iex> create_response(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_response(%Scope{} = scope, attrs) do
    with {:ok, %Response{} = response} <-
           %Response{}
           |> Response.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast("incident:#{response.incident_id}", {:response_created, response})

      {:ok, response}
    end
  end

  @doc """
  Updates a response.

  ## Examples

      iex> update_response(scope, response, %{field: new_value})
      {:ok, %Response{}}

      iex> update_response(scope, response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_response(%Scope{} = scope, %Response{} = response, attrs) do
    true = response.user_id == scope.user.id

    with {:ok, response = %Response{}} <-
           response
           |> Response.changeset(attrs, scope)
           |> Repo.update() do
      {:ok, response}
    end
  end

  @doc """
  Deletes a response.

  ## Examples

      iex> delete_response(scope, response)
      {:ok, %Response{}}

      iex> delete_response(scope, response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_response(%Scope{} = scope, %Response{} = response) do
    true = response.user_id == scope.user.id

    with {:ok, response = %Response{}} <-
           Repo.delete(response) do
      {:ok, response}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking response changes.

  ## Examples

      iex> change_response(scope, response)
      %Ecto.Changeset{data: %Response{}}

  """
  def change_response(%Scope{} = scope, %Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs, scope)
  end
end
