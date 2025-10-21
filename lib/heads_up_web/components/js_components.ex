defmodule HeadsUpWeb.JSComponents do
  use Phoenix.Component
  use HeadsUpWeb, :html

  def delete_and_hide(js \\ %JS{}, dom_id, raffle) do
    js
    |> JS.push("delete", value: %{id: raffle.id})
    |> JS.hide(to: "##{dom_id}", transition: "fade-out")
  end
end
