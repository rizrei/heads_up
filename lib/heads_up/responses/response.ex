defmodule HeadsUp.Responses.Response do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id
  schema "responses" do
    field :note, :string
    field :status, Ecto.Enum, values: [:enroute, :arrived, :departed]

    belongs_to :incident, HeadsUp.Incidents.Incident
    belongs_to :user, HeadsUp.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(response, attrs, user_scope) do
    response
    |> cast(attrs, [:note, :status, :incident_id])
    |> validate_required([:status, :incident_id])
    |> validate_length(:note, max: 500)
    |> put_change(:user_id, user_scope.user.id)
    |> assoc_constraint(:user)
    |> assoc_constraint(:incident)
  end
end
