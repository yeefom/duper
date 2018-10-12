defmodule Duper.Gatherer do
  use GenServer

  @me __MODULE__

  def start_link(worker_count) do
    GenServer.start_link(@me, worker_count, name: @me)
  end

  def done() do
    GenServer.cast(@me, :done)
  end

  def add_result(hash, path) do
    GenServer.cast(@me, { :add_result, hash, path})
  end

  def init(worker_count) do
    Process.send_after(self(), :kickoff_workers, 0)
    { :ok, worker_count }
  end

  def handle_cast(:done, _worker_count = 1) do
    report_results()
    System.halt(0)
  end

  def handle_cast(:done, worker_count) do
    { :noreply, worker_count - 1 }
  end

  def handle_cast({ :add_result, hash, path }, worker_count) do
    Duper.Results.add(hash, path)
    { :noreply, worker_count }
  end

  def handle_info(:kickoff_workers, worker_count) do
    1..worker_count |> Enum.each(fn _ -> Duper.WorkerSupervisor.add_worker() end)

    { :noreply, worker_count }
  end

  defp report_results() do
    IO.puts "Results:\n"
    Duper.Results.find_duplicates()
    |> Enum.each(&IO.inspect/1)
  end
end
