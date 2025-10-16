defmodule HeadsUpWeb.EffortLive.Show do
  use HeadsUpWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: send_tick()

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

        <form phx-change="set_minutes">
          <label>Minutes Per Responder:</label>
          <input type="number" name="minutes" value={@minutes_per_responder} />
        </form>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do
    socket = update(socket, :responders, &(&1 + String.to_integer(quantity)))
    {:noreply, socket}
  end

  def handle_event("set_minutes", %{"minutes" => minutes}, socket) do
    socket = assign(socket, :minutes_per_responder, String.to_integer(minutes))
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    send_tick()
    socket = update(socket, :responders, &(&1 + 3))

    {:noreply, socket}
  end

  defp send_tick() do
    Process.send_after(self(), :tick, :timer.seconds(2))
  end
end
