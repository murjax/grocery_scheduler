defmodule GroceryScheduler.Repo.Migrations.RenameItemsFrequencyDaysToFrequencyWeeks do
  use Ecto.Migration

  def change do
    rename table(:items), :frequency_days, to: :frequency_weeks
  end
end
