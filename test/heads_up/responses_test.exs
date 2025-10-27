defmodule HeadsUp.ResponsesTest do
  use HeadsUp.DataCase

  alias HeadsUp.Responses
  alias HeadsUp.Responses.Response

  import HeadsUp.AccountsFixtures, only: [user_scope_fixture: 0]
  import HeadsUp.ResponsesFixtures
  import HeadsUp.IncidentsFixtures

  setup do
    incident = incident_fixture()
    scope = user_scope_fixture()
    response = response_fixture(scope, incident_id: incident.id)
    %{scope: scope, response: response, incident: incident}
  end

  describe "responses" do
    test "list_responses/1 returns all scoped responses", %{
      scope: scope,
      response: response,
      incident: incident
    } do
      other_scope = user_scope_fixture()
      other_response = response_fixture(other_scope, incident_id: incident.id)
      assert Responses.list_responses(scope) == [response]
      assert Responses.list_responses(other_scope) == [other_response]
    end

    test "get_response!/2 returns the response with given id", %{scope: scope, response: response} do
      other_scope = user_scope_fixture()
      assert Responses.get_response!(scope, response.id) == response

      assert_raise Ecto.NoResultsError, fn ->
        Responses.get_response!(other_scope, response.id)
      end
    end

    test "create_response/2 with valid data creates a response", %{
      scope: scope,
      incident: incident
    } do
      valid_attrs = %{status: :enroute, note: "some note", incident_id: incident.id}

      assert {:ok, %Response{} = response} = Responses.create_response(scope, valid_attrs)
      assert response.status == :enroute
      assert response.note == "some note"
      assert response.user_id == scope.user.id
      assert response.incident_id == incident.id
    end

    test "create_response/2 with invalid data returns error changeset", %{scope: scope} do
      invalid_attrs = %{status: nil, note: nil}
      assert {:error, %Ecto.Changeset{}} = Responses.create_response(scope, invalid_attrs)
    end

    test "update_response/3 with valid data updates the response", %{
      scope: scope,
      response: response
    } do
      update_attrs = %{status: :arrived, note: "some updated note"}

      assert {:ok, %Response{} = response} =
               Responses.update_response(scope, response, update_attrs)

      assert response.status == :arrived
      assert response.note == "some updated note"
    end

    test "update_response/3 with invalid scope raises", %{response: response} do
      other_scope = user_scope_fixture()

      assert_raise MatchError, fn ->
        Responses.update_response(other_scope, response, %{})
      end
    end

    test "update_response/3 with invalid data returns error changeset", %{
      scope: scope,
      response: response
    } do
      invalid_attrs = %{status: nil, note: nil}

      assert {:error, %Ecto.Changeset{}} =
               Responses.update_response(scope, response, invalid_attrs)

      assert response == Responses.get_response!(scope, response.id)
    end

    test "delete_response/2 deletes the response", %{scope: scope, response: response} do
      assert {:ok, %Response{}} = Responses.delete_response(scope, response)
      assert_raise Ecto.NoResultsError, fn -> Responses.get_response!(scope, response.id) end
    end

    test "delete_response/2 with invalid scope raises", %{response: response} do
      other_scope = user_scope_fixture()
      assert_raise MatchError, fn -> Responses.delete_response(other_scope, response) end
    end

    test "change_response/2 returns a response changeset", %{response: response} do
      assert %Ecto.Changeset{} = Responses.change_response(response)
    end
  end
end
