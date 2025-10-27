defmodule HeadsUp.EventBus.PubSub do
  @moduledoc """
  Centralized PubSub helper for HeadsUp.
  Handles topic naming, subscriptions, and broadcasting.
  """

  alias Phoenix.PubSub

  @doc """
    Subscribes to scoped notifications about any changes.
  """
  def subscribe(topic, opts \\ []), do: PubSub.subscribe(HeadsUp.PubSub, topic, opts)

  def unsubscribe(topic), do: PubSub.unsubscribe(HeadsUp.PubSub, topic)

  def broadcast(topic, message), do: PubSub.broadcast(HeadsUp.PubSub, topic, message)
  def local_broadcast(topic, message), do: PubSub.local_broadcast(HeadsUp.PubSub, topic, message)
end
