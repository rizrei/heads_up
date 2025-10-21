defmodule HeadsUp.Admin.Categories do
  use HeadsUp, :query

  alias HeadsUp.Categories.Category

  def categories_names_and_ids do
    Category
    |> order_by(:name)
    |> select([c], {c.name, c.id})
    |> Repo.all()
  end
end
