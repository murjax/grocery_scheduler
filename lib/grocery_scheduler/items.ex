defmodule GroceryScheduler.Items do
  @moduledoc """
  The Items context.
  """

  import Ecto.Query, warn: false
  alias GroceryScheduler.Repo

  alias GroceryScheduler.Items.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  @doc """
    Returns items scheduled for purchase this week.
    A week in Elixir and Postgres starts on Monday and ends on Sunday.

    Inclusions:
    - Items with a frequency week of 1
    - Items where lapsed weeks divide fully with frequency weeks.
      - Example: Frequency week 3 - 3, 6, 9 weeks lapsed.
    - Items starting or ending this week.

    Exclusions:
    - Items ended in previous weeks.
    - Items starting in future weeks.
    - items where lapsed weeks dividely fractionally with frequency weeks.
      - Example: Frequency week 3 - 1, 2, 5 weeks lapsed.
  """
  def items_for_week() do
    Date.utc_today() |> items_for_week()
  end

  def items_for_week(date) do
    week_start = Date.beginning_of_week(date)
    end_week = Date.end_of_week(date)

    Ecto.Query.from(
      i in Item,
      where: i.start_at <= ^end_week,
      where: is_nil(i.end_at) or i.end_at >= ^week_start,
      where: fragment(
        "MOD(DATE_PART('day', ((DATE_TRUNC('week', ?::date) + interval '6 days') - ?::date))::integer, ?::integer) = 0",
        i.start_at, ^end_week, i.frequency_weeks
      )
    )
    |> Repo.all()
  end
end
