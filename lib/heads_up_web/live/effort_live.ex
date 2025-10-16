defmodule HeadsUpWeb.EffortLive do
  use HeadsUpWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        responders: 0,
        minutes_per_responder: 10
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="effort">
        <h1>Community Love</h1>
        <section>
          <button phx-click="add" , phx-value-quantity="3">
            + 3
          </button>
          <div>{@responders}</div>
          &times;
          <div>{@minutes_per_responder} minutes</div>
          =
          <div>{@responders * @minutes_per_responder} minutes</div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do
    socket = update(socket, :responders, &(&1 + String.to_integer(quantity)))
    {:noreply, socket}
  end
end
