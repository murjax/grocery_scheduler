defmodule GroceryScheduler.Repo.Migrations.AddFrequencyDaysToItems do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :frequency_days, :integer
    end
  end
end
