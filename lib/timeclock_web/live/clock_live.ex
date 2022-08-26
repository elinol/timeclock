defmodule TimeclockWeb.ClockLive do
  use TimeclockWeb, :live_view

  def mount(_params, _session, socket) do
    title = "not started"

    socket =
      socket
      |> assign(
          title: title,
          counter: 0,
          total_time: 0,
          timer_ref: nil,
          started: false
      )

    {:ok, socket}
  end

  def handle_event("start", _session, socket) do
    start_time = DateTime.utc_now

    timer_ref = :timer.send_interval(1000, self(), :tick)


    socket =
      socket
      |> assign(
          title: "started",
          start_time: start_time,
          counter: 0,
          timer_ref: timer_ref,
          started: true
      )

    {:noreply, socket}
  end


  def handle_info(:tick, %{assigns: %{counter: counter}} = socket) do
      {:noreply, socket |> assign(:counter, counter + 1)}
  end

  def handle_event("stop", _session, socket) do
    stop_time = DateTime.utc_now

    counted_time = DateTime.diff(stop_time, socket.assigns.start_time)
    :timer.cancel(socket.assigns.timer_ref)

    socket =
      socket
      |> assign(
          title: "stopped",
          counter: 0,
          total_time: socket.assigns.total_time + counted_time,
          timer_ref: nil,
          started: false

      )
    {:noreply, socket}

  end
end
