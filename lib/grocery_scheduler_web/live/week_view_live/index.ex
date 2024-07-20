defmodule GrocerySchedulerWeb.WeekViewLive.Index do
  use GrocerySchedulerWeb, :live_view

  alias GroceryScheduler.Items

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
