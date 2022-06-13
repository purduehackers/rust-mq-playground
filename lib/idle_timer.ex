defmodule IdleTimer do
  use Agent

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

  def wait_for_process(pid) do
    if Process.alive?(pid) do
      IdleTimer.reset_timer()
      Process.sleep(1000)
      wait_for_process(pid)
    end
  end
end
