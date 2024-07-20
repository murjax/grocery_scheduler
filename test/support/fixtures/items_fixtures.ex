defmodule GroceryScheduler.ItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GroceryScheduler.Items` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        end_at: ~D[2024-07-13],
        name: "some name",
        price: "120.5",
        start_at: ~D[2024-07-13],
        frequency_weeks: 7,
        user_id: GroceryScheduler.AccountsFixtures.user_fixture().id
      })
      |> GroceryScheduler.Items.create_item()

    item
  end
end
