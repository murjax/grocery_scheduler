defmodule GrocerySchedulerWeb.WeekViewLive.Index do
  use GrocerySchedulerWeb, :live_view

  alias GroceryScheduler.Items
  alias GroceryScheduler.Items.Item

  @impl true
  def mount(_params, session, socket) do
    user = GroceryScheduler.Accounts.get_user_by_session_token(session["user_token"])
    week_info = Date.utc_today() |> week_info_for_date()
    socket = assign(
      socket,
      user_id: user.id,
      week_start: week_info.week_start,
      week_end: week_info.week_end,
      formatted_week_start: week_info.formatted_week_start,
      formatted_week_end: week_info.formatted_week_end
    )
    {:ok, stream(socket, :items, Items.items_for_week(week_info.week_start))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Items.get_item!(id))
  end

  defp apply_action(socket, :new, %{"week_start" => week_start, "week_end" => week_end}) do
    {:ok, start_at} = Date.from_iso8601(week_start)
    {:ok, end_at} = Date.from_iso8601(week_end)

    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{start_at: start_at, end_at: end_at, frequency_weeks: 1})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_info({GrocerySchedulerWeb.ItemLive.FormComponent, {:saved, item}}, socket) do
    {:noreply, stream_insert(socket, :items, item)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Items.get_item!(id)
    {:ok, _} = Items.delete_item(item)

    {:noreply, stream_delete(socket, :items, item)}
  end

  def handle_event("last_week", _, socket) do
    week_info = socket.assigns.week_start |> Date.add(-7) |> week_info_for_date()
    socket = assign(
      socket,
      week_start: week_info.week_start,
      week_end: week_info.week_end,
      formatted_week_start: week_info.formatted_week_start,
      formatted_week_end: week_info.formatted_week_end
    )
    {:noreply, stream(socket, :items, Items.items_for_week(week_info.week_start), reset: true)}
  end

  def handle_event("next_week", _, socket) do
    week_info = socket.assigns.week_start |> Date.add(7) |> week_info_for_date()
    socket = assign(
      socket,
      week_start: week_info.week_start,
      week_end: week_info.week_end,
      formatted_week_start: week_info.formatted_week_start,
      formatted_week_end: week_info.formatted_week_end
    )
    {:noreply, stream(socket, :items, Items.items_for_week(week_info.week_start), reset: true)}
  end

  defp week_info_for_date(date) do
    week_start = Date.beginning_of_week(date)
    week_end = Date.end_of_week(date)
    formatted_week_start = Calendar.strftime(week_start, "%m/%d/%Y")
    formatted_week_end = Calendar.strftime(week_end, "%m/%d/%Y")

    %{
      week_start: week_start,
      week_end: week_end,
      formatted_week_start: formatted_week_start,
      formatted_week_end: formatted_week_end
    }
  end
end
