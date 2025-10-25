defmodule HeadsUp do
  @moduledoc """
  HeadsUp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def query do
    quote do
      import Ecto.Query

      alias HeadsUp.Repo
    end
  end

  def pub_sub do
    quote do
      import HeadsUp.EventBus.PubSub
    end
  end

  @doc """
  When used, dispatch to the appropriate query.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
