defmodule GroceryScheduler.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :price, :decimal
      add :start_at, :date
      add :end_at, :date

      timestamps(type: :utc_datetime)
    end
  end
end
