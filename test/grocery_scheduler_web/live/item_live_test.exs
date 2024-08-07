defmodule GrocerySchedulerWeb.ItemLiveTest do
  use GrocerySchedulerWeb.ConnCase

  import Phoenix.LiveViewTest
  import GroceryScheduler.ItemsFixtures
  import GroceryScheduler.AccountsFixtures

  @create_attrs %{
    end_at: "2024-07-13",
    name: "some name",
    start_at: "2024-07-13",
    price: "120.5",
    frequency_weeks: 1
  }
  @update_attrs %{
    name: "some updated name",
    start_at: "2024-07-14",
    end_at: "2024-07-14",
    price: "456.7",
    frequency_weeks: 2
  }
  @invalid_attrs %{
    start_at: nil,
    name: nil,
    price: nil,
    frequency_weeks: nil
  }

  defp create_item_and_user(%{conn: conn}) do
    item = item_fixture()
    user = user_fixture()
    token = GroceryScheduler.Accounts.generate_user_session_token(user)
    conn = conn |> Phoenix.ConnTest.init_test_session(%{}) |> Plug.Conn.put_session("user_token", token)

    %{item: item, conn: conn}
  end

  describe "Index" do
    setup [:create_item_and_user]

    test "lists all items", %{conn: conn, item: item} do
      {:ok, _index_live, html} = live(conn, ~p"/items")

      # Data
      assert html =~ "Listing Items"
      assert html =~ "Name"
      assert html =~ "Price"
      assert html =~ "Purchase Frequency (Weeks)"
      assert html =~ "Start At"
      assert html =~ "End At"

      # Labels
      assert html =~ item.name
      assert html =~ Decimal.to_string(item.price)
      assert html =~ Integer.to_string(item.frequency_weeks)
      assert html =~ Date.to_string(item.start_at)
      assert html =~ Date.to_string(item.end_at)
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert index_live |> element("a", "New Item") |> render_click() =~
               "New Item"

      assert_patch(index_live, ~p"/items/new")

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#item-form", item: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/items")

      html = render(index_live)
      assert html =~ "Item created successfully"
      assert html =~ "some name"
    end

    test "updates item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert index_live |> element("#items-#{item.id} a", "Edit") |> render_click() =~
               "Edit Item"

      assert_patch(index_live, ~p"/items/#{item}/edit")

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#item-form", item: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/items")

      html = render(index_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert index_live |> element("#items-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#items-#{item.id}")
    end
  end

  describe "Show" do
    setup [:create_item_and_user]

    test "displays item", %{conn: conn, item: item} do
      {:ok, _show_live, html} = live(conn, ~p"/items/#{item}")

      # Labels
      assert html =~ "Show Item"
      assert html =~ "Name"
      assert html =~ "Price"
      assert html =~ "Purchase Frequency (Weeks)"
      assert html =~ "Start At"
      assert html =~ "End At"

      # Data
      assert html =~ item.name
      assert html =~ Decimal.to_string(item.price)
      assert html =~ Integer.to_string(item.frequency_weeks)
      assert html =~ Date.to_string(item.start_at)
      assert html =~ Date.to_string(item.end_at)
    end

    test "updates item within modal", %{conn: conn, item: item} do
      {:ok, show_live, _html} = live(conn, ~p"/items/#{item}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Item"

      assert_patch(show_live, ~p"/items/#{item}/show/edit")

      assert show_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#item-form", item: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/items/#{item}")

      html = render(show_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated name"
    end
  end
end
