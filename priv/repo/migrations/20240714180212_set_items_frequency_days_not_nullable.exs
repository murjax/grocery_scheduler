defmodule GroceryScheduler.Repo.Migrations.SetItemsFrequencyDaysNotNullable do
  use Ecto.Migration

  def change do
    alter table(:items) do
      modify :frequency_days, :integer, null: false
    end
  end
end
