defmodule IdleTimer do
  use Agent

  @moduledoc """
  The IdleTimer keeps track of how long it's been since the last request.
  It's used to shut the process off after a set time, specified by the argument
  passed in by server_app.ex

  Shutting the process down is useful because Fly machines scale to zero, so
  I can keep hosting costs down even with a reasonably powerful server
  """

  def start_link(timeout) do
    Agent.start_link(fn -> %{base: timeout, remaining: timeout} end, name: __MODULE__)
    Task.start_link(fn -> decrement_loop() end)
  end

  def remaining_time() do
    Agent.get(__MODULE__, fn %{remaining: t} -> t end)
  end

  def reset_timer() do
    Agent.update(__MODULE__, fn %{base: base} = s -> %{s | remaining: base} end)
  end

  def decrement_time() do
    Agent.update(__MODULE__, fn %{remaining: t} = s -> %{s | remaining: t - 1} end)
  end

  def decrement_loop() do
    if remaining_time() > 0 do
      decrement_time()
      Process.sleep(1000)
      decrement_loop()
    else
      IO.puts("No requests, shutting down")
      System.stop(0)
    end
  end

  # Used to prevent the server from shutting down
  # while compiling a program
  def wait_for_process(pid) do
    if Process.alive?(pid) do
      IdleTimer.reset_timer()
      Process.sleep(1000)
      wait_for_process(pid)
    end
  end
end

defmodule IdleTimerPlug do
  def init(options), do: options

  def call(conn, _opts) do
    IdleTimer.reset_timer()
    conn
  end
end
