defmodule HeadsUp.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :note, :text
      add :status, :string
      add :incident_id, references(:incidents, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:responses, [:incident_id])
    create index(:responses, [:user_id])
  end
end
