defmodule HeadsUpWeb.HeadlineComponents do
  use Phoenix.Component

  slot :inner_block, required: true
  slot :tagline

  def headline(assigns) do
    assigns = assign_new(assigns, :emoji, fn -> ~w(😎 🤩 🥳) |> Enum.random() end)

    ~H"""
    <div class="headline">
      <h1>
        {render_slot(@inner_block)}
      </h1>
      <div :for={tagline <- @tagline} class="tagline">
        {render_slot(tagline, @emoji)}
      </div>
    </div>
    """
  end
end
