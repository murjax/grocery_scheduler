defmodule GroceryScheduler.Repo do
  use Ecto.Repo,
    otp_app: :grocery_scheduler,
    adapter: Ecto.Adapters.Postgres
end
