defmodule GroceryScheduler.ItemsTest do
  use GroceryScheduler.DataCase

  alias GroceryScheduler.Items

  describe "items" do
    alias GroceryScheduler.Items.Item

    import GroceryScheduler.ItemsFixtures
    import GroceryScheduler.AccountsFixtures

    @invalid_attrs %{start_at: nil, name: nil, price: nil, frequency_weeks: nil, user_id: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Items.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Items.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      user = user_fixture()
      valid_attrs = %{
        start_at: ~D[2024-07-13],
        end_at: ~D[2024-07-13],
        name: "some name",
        price: "120.5",
        frequency_weeks: 7,
        user_id: user.id
      }

      assert {:ok, %Item{} = item} = Items.create_item(valid_attrs)
      assert item.start_at == ~D[2024-07-13]
      assert item.end_at == ~D[2024-07-13]
      assert item.name == "some name"
      assert item.price == Decimal.new("120.5")
      assert item.frequency_weeks == 7
      assert item.user_id == user.id
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Items.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      user = user_fixture()
      update_attrs = %{
        start_at: ~D[2024-07-14],
        end_at: ~D[2024-07-14],
        name: "some updated name",
        price: "456.7",
        frequency_weeks: 8,
        user_id: user.id
      }

      assert {:ok, %Item{} = item} = Items.update_item(item, update_attrs)
      assert item.start_at == ~D[2024-07-14]
      assert item.end_at == ~D[2024-07-14]
      assert item.name == "some updated name"
      assert item.price == Decimal.new("456.7")
      assert item.frequency_weeks == 8
      assert item.user_id == user.id
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

    test "items_for_week/0" do
      user = user_fixture()
      date = Date.utc_today()

      # Item started today
      item1 = item_fixture(%{user_id: user.id, start_at: date, end_at: nil, frequency_weeks: 1})
      # Item ended today
      item2 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: date, frequency_weeks: 1})
      # Item purchase frequency two weeks and item created two weeks ago.
      item3 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 2})
      # Item ending next week
      item4 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: Date.add(date, 7), frequency_weeks: 1})
      # Item purchase frequency three weeks and item created three weeks ago.
      item5 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -21), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created six weeks ago.
      item6 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -42), end_at: nil, frequency_weeks: 3})

      # Item purchase frequency two weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 2})
      # Item ended last week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -10), end_at: Date.add(date, -7), frequency_weeks: 1})
      # Item starting next week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, 7), end_at: nil, frequency_weeks: 1})
      # Item purchase frequency three weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created two weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created four weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -28), end_at: nil, frequency_weeks: 3})

      assert Items.items_for_week(date) == [item1, item2, item3, item4, item5, item6]
    end

    test "items_for_week/1 Monday" do
      user = user_fixture()
      date = ~D[2024-07-15]

      # Item started yesterday, purchase weekly
      item1 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: nil, frequency_weeks: 1})
      # Item started today
      item2 = item_fixture(%{user_id: user.id, start_at: date, end_at: nil, frequency_weeks: 1})
      # Item starting this week
      item3 = item_fixture(%{user_id: user.id, start_at: Date.add(date, 1), end_at: nil, frequency_weeks: 1})
      # Item ended today
      item4 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: date, frequency_weeks: 1})
      # Item ending later this week
      item5 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: Date.add(date, 1), frequency_weeks: 1})
      # Item purchase frequency two weeks and item created two weeks ago.
      item6 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -9), end_at: nil, frequency_weeks: 2})
      # Item ending next week
      item7 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: Date.add(date, 7), frequency_weeks: 1})
      # Item purchase frequency three weeks and item created three weeks ago.
      item8 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -15), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created six weeks ago.
      item9 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -40), end_at: nil, frequency_weeks: 3})

      # Item purchase frequency two weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -3), end_at: nil, frequency_weeks: 2})
      # Item ended last week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -10), end_at: Date.add(date, -2), frequency_weeks: 1})
      # Item starting next week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, 7), end_at: nil, frequency_weeks: 1})
      # Item purchase frequency three weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -3), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created two weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -9), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created four weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -22), end_at: nil, frequency_weeks: 3})

      assert Items.items_for_week(date) == [item1, item2, item3, item4, item5, item6, item7, item8, item9]
    end

    test "items_for_week/1 Tuesday" do
      user = user_fixture()
      date = ~D[2024-07-16]

      # Item started yesterday, purchase weekly
      item1 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: nil, frequency_weeks: 1})
      # Item started today
      item2 = item_fixture(%{user_id: user.id, start_at: date, end_at: nil, frequency_weeks: 1})
      # Item starting this week
      item3 = item_fixture(%{user_id: user.id, start_at: Date.add(date, 1), end_at: nil, frequency_weeks: 1})
      # Item ended today
      item4 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: date, frequency_weeks: 1})
      # Item ending later this week
      item5 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: Date.add(date, 1), frequency_weeks: 1})
      # Item purchase frequency two weeks and item created two weeks ago.
      item6 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 2})
      # Item ending next week
      item7 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: Date.add(date, 7), frequency_weeks: 1})
      # Item purchase frequency three weeks and item created three weeks ago.
      item8 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -21), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created six weeks ago.
      item9 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -42), end_at: nil, frequency_weeks: 3})

      # Item purchase frequency two weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 2})
      # Item ended last week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -20), end_at: Date.add(date, -7), frequency_weeks: 1})
      # Item starting next week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, 7), end_at: nil, frequency_weeks: 1})
      # Item purchase frequency three weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created two weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created four weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -28), end_at: nil, frequency_weeks: 3})

      assert Items.items_for_week(date) == [item1, item2, item3, item4, item5, item6, item7, item8, item9]
    end

    test "items_for_week/1 Wednesday" do
      user = user_fixture()
      date = ~D[2024-07-17]

      # Item started yesterday, purchase weekly
      item1 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: nil, frequency_weeks: 1})
      # Item started today
      item2 = item_fixture(%{user_id: user.id, start_at: date, end_at: nil, frequency_weeks: 1})
      # Item starting this week
      item3 = item_fixture(%{user_id: user.id, start_at: Date.add(date, 1), end_at: nil, frequency_weeks: 1})
      # Item ended today
      item4 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: date, frequency_weeks: 1})
      # Item ending later this week
      item5 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: Date.add(date, 1), frequency_weeks: 1})
      # Item purchase frequency two weeks and item created two weeks ago.
      item6 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 2})
      # Item ending next week
      item7 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: Date.add(date, 7), frequency_weeks: 1})
      # Item purchase frequency three weeks and item created three weeks ago.
      item8 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -21), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created six weeks ago.
      item9 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -42), end_at: nil, frequency_weeks: 3})

      # Item purchase frequency two weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 2})
      # Item ended last week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -20), end_at: Date.add(date, -7), frequency_weeks: 1})
      # Item starting next week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, 7), end_at: nil, frequency_weeks: 1})
      # Item purchase frequency three weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created two weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created four weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -28), end_at: nil, frequency_weeks: 3})

      assert Items.items_for_week(date) == [item1, item2, item3, item4, item5, item6, item7, item8, item9]
    end

    test "items_for_week/1 Thursday" do
      user = user_fixture()
      date = ~D[2024-07-18]

      # Item started yesterday, purchase weekly
      item1 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: nil, frequency_weeks: 1})
      # Item started today
      item2 = item_fixture(%{user_id: user.id, start_at: date, end_at: nil, frequency_weeks: 1})
      # Item starting this week
      item3 = item_fixture(%{user_id: user.id, start_at: Date.add(date, 1), end_at: nil, frequency_weeks: 1})
      # Item ended today
      item4 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: date, frequency_weeks: 1})
      # Item ending later this week
      item5 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: Date.add(date, 1), frequency_weeks: 1})
      # Item purchase frequency two weeks and item created two weeks ago.
      item6 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 2})
      # Item ending next week
      item7 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: Date.add(date, 7), frequency_weeks: 1})
      # Item purchase frequency three weeks and item created three weeks ago.
      item8 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -21), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created six weeks ago.
      item9 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -42), end_at: nil, frequency_weeks: 3})

      # Item purchase frequency two weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 2})
      # Item ended last week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -20), end_at: Date.add(date, -7), frequency_weeks: 1})
      # Item starting next week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, 7), end_at: nil, frequency_weeks: 1})
      # Item purchase frequency three weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created two weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created four weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -28), end_at: nil, frequency_weeks: 3})

      assert Items.items_for_week(date) == [item1, item2, item3, item4, item5, item6, item7, item8, item9]
    end

    test "items_for_week/1 Friday" do
      user = user_fixture()
      date = ~D[2024-07-19]

      # Item started yesterday, purchase weekly
      item1 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: nil, frequency_weeks: 1})
      # Item started today
      item2 = item_fixture(%{user_id: user.id, start_at: date, end_at: nil, frequency_weeks: 1})
      # Item starting this week
      item3 = item_fixture(%{user_id: user.id, start_at: Date.add(date, 1), end_at: nil, frequency_weeks: 1})
      # Item ended today
      item4 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: date, frequency_weeks: 1})
      # Item ending later this week
      item5 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: Date.add(date, 1), frequency_weeks: 1})
      # Item purchase frequency two weeks and item created two weeks ago.
      item6 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 2})
      # Item ending next week
      item7 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: Date.add(date, 7), frequency_weeks: 1})
      # Item purchase frequency three weeks and item created three weeks ago.
      item8 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -21), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created six weeks ago.
      item9 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -42), end_at: nil, frequency_weeks: 3})

      # Item purchase frequency two weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 2})
      # Item ended last week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -20), end_at: Date.add(date, -7), frequency_weeks: 1})
      # Item starting next week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, 7), end_at: nil, frequency_weeks: 1})
      # Item purchase frequency three weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created two weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created four weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -28), end_at: nil, frequency_weeks: 3})

      assert Items.items_for_week(date) == [item1, item2, item3, item4, item5, item6, item7, item8, item9]
    end

    test "items_for_week/1 Saturday" do
      user = user_fixture()
      date = ~D[2024-07-19]

      # Item started yesterday, purchase weekly
      item1 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: nil, frequency_weeks: 1})
      # Item started today
      item2 = item_fixture(%{user_id: user.id, start_at: date, end_at: nil, frequency_weeks: 1})
      # Item starting this week
      item3 = item_fixture(%{user_id: user.id, start_at: Date.add(date, 1), end_at: nil, frequency_weeks: 1})
      # Item ended today
      item4 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: date, frequency_weeks: 1})
      # Item ending later this week
      item5 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: Date.add(date, 1), frequency_weeks: 1})
      # Item purchase frequency two weeks and item created two weeks ago.
      item6 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 2})
      # Item ending next week
      item7 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: Date.add(date, 7), frequency_weeks: 1})
      # Item purchase frequency three weeks and item created three weeks ago.
      item8 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -21), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created six weeks ago.
      item9 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -42), end_at: nil, frequency_weeks: 3})

      # Item purchase frequency two weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 2})
      # Item ended last week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -20), end_at: Date.add(date, -7), frequency_weeks: 1})
      # Item starting next week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, 7), end_at: nil, frequency_weeks: 1})
      # Item purchase frequency three weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created two weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created four weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -28), end_at: nil, frequency_weeks: 3})

      assert Items.items_for_week(date) == [item1, item2, item3, item4, item5, item6, item7, item8, item9]
    end

    test "items_for_week/1 Sunday" do
      user = user_fixture()
      date = ~D[2024-07-19]

      # Item started yesterday, purchase weekly
      item1 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: nil, frequency_weeks: 1})
      # Item started today
      item2 = item_fixture(%{user_id: user.id, start_at: date, end_at: nil, frequency_weeks: 1})
      # Item ended today
      item3 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -5), end_at: date, frequency_weeks: 1})
      # Item purchase frequency two weeks and item created two weeks ago.
      item4 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 2})
      # Item ending next week
      item5 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -1), end_at: Date.add(date, 7), frequency_weeks: 1})
      # Item purchase frequency three weeks and item created three weeks ago.
      item6 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -21), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created six weeks ago.
      item7 = item_fixture(%{user_id: user.id, start_at: Date.add(date, -42), end_at: nil, frequency_weeks: 3})

      # Item purchase frequency two weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 2})
      # Item ended last week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -20), end_at: Date.add(date, -7), frequency_weeks: 1})
      # Item starting next week
      item_fixture(%{user_id: user.id, start_at: Date.add(date, 7), end_at: nil, frequency_weeks: 1})
      # Item purchase frequency three weeks and item created last week.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -7), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created two weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -14), end_at: nil, frequency_weeks: 3})
      # Item purchase frequency three weeks and item created four weeks ago.
      item_fixture(%{user_id: user.id, start_at: Date.add(date, -28), end_at: nil, frequency_weeks: 3})

      assert Items.items_for_week(date) == [item1, item2, item3, item4, item5, item6, item7]
    end
  end
end
