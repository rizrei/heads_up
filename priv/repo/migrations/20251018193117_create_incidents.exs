defmodule HeadsUp.Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def change do
    create table(:incidents, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string
      add :description, :text
      add :priority, :integer
      add :status, :string
      add :image_path, :string

      timestamps(type: :utc_datetime)
    end
  end
end
