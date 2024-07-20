defmodule GrocerySchedulerWeb.WeekViewLive.Index do
  use GrocerySchedulerWeb, :live_view

  alias GroceryScheduler.Items

  @impl true
  def mount(_params, session, socket) do
    user = GroceryScheduler.Accounts.get_user_by_session_token(session["user_token"])
    socket = assign(socket, :user_id, user.id)
    {:ok, stream(socket, :items, Items.list_items())}
  end
end
