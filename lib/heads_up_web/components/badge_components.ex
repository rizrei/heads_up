defmodule HeadsUpWeb.BadgeComponents do
  use Phoenix.Component

  attr :status, :atom, values: [:upcoming, :open, :closed], default: :upcoming
  attr :class, :string, default: nil
  attr :rest, :global

  def badge(assigns) do
    ~H"""
    <div
      class={[
        "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
        @status == :resolved && "text-lime-600 border-lime-600",
        @status == :pending && "text-amber-600 border-amber-600",
        @status == :canceled && "text-gray-600 border-gray-600",
        @class
      ]}
      {@rest}
    >
      {@status}
    </div>
    """
  end
end
