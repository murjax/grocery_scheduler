defmodule GroceryScheduler.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :end_at, :date
    field :name, :string
    field :price, :decimal
    field :start_at, :date
    field :frequency_weeks, :integer
    belongs_to :user, GroceryScheduler.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :price, :frequency_weeks, :start_at, :end_at, :user_id])
    |> validate_required([:name, :price, :frequency_weeks, :start_at, :user_id])
  end
end
