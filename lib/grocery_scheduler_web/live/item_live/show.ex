defmodule GrocerySchedulerWeb.ItemLive.Show do
  use GrocerySchedulerWeb, :live_view

  alias GroceryScheduler.Items

  @impl true
  def mount(_params, session, socket) do
    user = GroceryScheduler.Accounts.get_user_by_session_token(session["user_token"])
    socket = assign(socket, :user_id, user.id)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:item, Items.get_item!(id))}
  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:edit), do: "Edit Item"
end
