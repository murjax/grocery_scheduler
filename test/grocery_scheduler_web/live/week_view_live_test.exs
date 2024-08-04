defmodule GrocerySchedulerWeb.WeekViewLiveTest do
  use GrocerySchedulerWeb.ConnCase

  import Phoenix.LiveViewTest
  import GroceryScheduler.ItemsFixtures
  import GroceryScheduler.AccountsFixtures

  @create_attrs %{
    name: "some name",
    price: "120.5",
    frequency_weeks: 1
  }
  @update_attrs %{
    name: "some updated name",
    price: "456.7",
    frequency_weeks: 2
  }
  @invalid_attrs %{
    name: nil,
    price: nil,
    frequency_weeks: nil
  }

  defp create_items_and_user(%{conn: conn}) do
    user = user_fixture()
    token = GroceryScheduler.Accounts.generate_user_session_token(user)
    conn = conn |> Phoenix.ConnTest.init_test_session(%{}) |> Plug.Conn.put_session("user_token", token)

    date = Date.utc_today()
    # Show
    # Item started today
    item1 = item_fixture(%{name: "Item1", user_id: user.id, start_at: date, end_at: Date.add(date, 20), frequency_weeks: 1})
    # Item purchase frequency three weeks and item created three weeks ago.
    item2 = item_fixture(%{name: "Item2", user_id: user.id, start_at: Date.add(date, -21), end_at: Date.add(date, 20), frequency_weeks: 3})

    # Do not show
    # Item purchase frequency three weeks and item created four weeks ago.
    item3 = item_fixture(%{name: "Item3", user_id: user.id, start_at: Date.add(date, -28), end_at: Date.add(date, 20), frequency_weeks: 3})
    # Item ended last week
    item4 = item_fixture(%{name: "Item4", user_id: user.id, start_at: Date.add(date, -10), end_at: Date.add(date, -7), frequency_weeks: 1})
    # Item starting next week
    item5 = item_fixture(%{name: "Item5", user_id: user.id, start_at: Date.add(date, 7), end_at: Date.add(date, 20), frequency_weeks: 1})

    %{items: [item1, item2, item3, item4, item5], conn: conn}
  end

  describe "Index" do
    setup [:create_items_and_user]

    test "lists items for current week", %{conn: conn, items: [item1, item2, item3, item4, item5]} do
      {:ok, _index_live, html} = live(conn, ~p"/schedule")

      # Labels
      assert html =~ "Listing Items"
      assert html =~ "Name"
      assert html =~ "Price"
      assert html =~ "Purchase Frequency (Weeks)"

      # Data
      assert html =~ item1.name
      assert html =~ Decimal.to_string(item1.price)

      assert html =~ item2.name
      assert html =~ Decimal.to_string(item2.price)

      item_total = Decimal.add(item1.price, item2.price)
      assert html =~ Decimal.to_string(item_total)

      assert String.contains?(html, item3.name) == false
      assert String.contains?(html, item4.name) == false
      assert String.contains?(html, item5.name) == false
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/schedule")

      assert index_live |> element("a", "New Item") |> render_click() =~
               "New Item"

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#item-form", item: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/schedule")

      html = render(index_live)
      assert html =~ "Item created successfully"
      assert html =~ "some name"
    end

    test "updates item in listing", %{conn: conn, items: [item | _]} do
      {:ok, index_live, _html} = live(conn, ~p"/schedule")

      assert index_live |> element("#items-#{item.id} a", "Edit") |> render_click() =~
               "Edit Item"

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#item-form", item: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/schedule")

      html = render(index_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes item in listing", %{conn: conn, items: [item | _]} do
      {:ok, index_live, _html} = live(conn, ~p"/schedule")

      assert index_live |> element("#items-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#items-#{item.id}")
    end
  end
end
