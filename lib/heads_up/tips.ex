defmodule HeadsUp.Tips do
  @moduledoc """
  The Tips context.
  """

  @type tip :: %{id: integer(), text: String.t()}

  @spec list_tips() :: [tip()]
  def list_tips do
    [
      %{
        id: 1,
        text: "Slow is smooth, and smooth is fast! 🐢"
      },
      %{
        id: 2,
        text: "Working with a buddy is always a smart move. 👯‍♂️"
      },
      %{
        id: 3,
        text: "Take it easy and enjoy! 😊"
      }
    ]
  end

  @spec get_tip(integer() | String.t()) :: tip() | nil
  def get_tip(id) when is_integer(id) do
    list_tips() |> Enum.find(&(&1.id == id))
  end

  def get_tip(id) when is_binary(id) do
    id |> String.to_integer() |> get_tip()
  end
end
