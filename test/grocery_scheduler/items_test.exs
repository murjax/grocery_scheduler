defmodule GroceryScheduler.ItemsTest do
  use GroceryScheduler.DataCase

  alias GroceryScheduler.Items

  describe "items" do
    alias GroceryScheduler.Items.Item

    import GroceryScheduler.ItemsFixtures

    @invalid_attrs %{end_at: nil, name: nil, price: nil, start_at: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Items.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Items.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{end_at: ~D[2024-07-13], name: "some name", price: "120.5", start_at: ~D[2024-07-13]}

      assert {:ok, %Item{} = item} = Items.create_item(valid_attrs)
      assert item.end_at == ~D[2024-07-13]
      assert item.name == "some name"
      assert item.price == Decimal.new("120.5")
      assert item.start_at == ~D[2024-07-13]
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Items.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{end_at: ~D[2024-07-14], name: "some updated name", price: "456.7", start_at: ~D[2024-07-14]}

      assert {:ok, %Item{} = item} = Items.update_item(item, update_attrs)
      assert item.end_at == ~D[2024-07-14]
      assert item.name == "some updated name"
      assert item.price == Decimal.new("456.7")
      assert item.start_at == ~D[2024-07-14]
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Items.update_item(item, @invalid_attrs)
      assert item == Items.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Items.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Items.change_item(item)
    end
  end
end
