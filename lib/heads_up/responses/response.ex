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
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:note, :status, :incident_id, :user_id])
    |> validate_required([:status, :incident_id, :user_id])
    |> validate_length(:note, max: 500)
    |> assoc_constraint(:user)
    |> assoc_constraint(:incident)
  end
end
