defmodule HeadsUpWeb.TipController do
  use HeadsUpWeb, :controller

  alias HeadsUp.Tips

  def index(conn, _params) do
    conn
    |> assign(:tips, Tips.list_tips())
    |> assign(:emojis, ~w(💚 💜 💙) |> Enum.random() |> String.duplicate(5))
    |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    conn
    |> assign(:tip, Tips.get_tip(id))
    |> assign(:answer, ~w(Yes No Maybe) |> Enum.random())
    |> render(:show)
  end
end
