defmodule HeadsUpWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :heads_up,
    pubsub_server: HeadsUp.PubSub

  use HeadsUp, :pub_sub

  def track_user(topic, user) do
    {:ok, _} =
      track(self(), topic, user.name, %{online_at: System.system_time(:second)})
  end

  def list_users(topic) do
    list(topic)
    |> Enum.map(fn {id, %{metas: metas}} -> %{id: id, metas: metas} end)
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, _presence} <- joins do
      msg = {:user_joined, %{id: user_id, metas: Map.fetch!(presences, user_id)}}

      local_broadcast("updates:#{topic}", msg)
    end

    for {user_id, _presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      local_broadcast("updates:#{topic}", {:user_left, %{id: user_id, metas: metas}})
    end

    {:ok, state}
  end
end
