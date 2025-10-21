defmodule HeadsUp.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "categories" do
    field :name, :string
    field :slug, :string

    has_many :incidents, HeadsUp.Incidents.Incident, on_delete: :nilify_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
