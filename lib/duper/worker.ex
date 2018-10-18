defmodule Duper.Worker do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    Process.send_after(self(), :process_file, 0)
    { :ok, nil }
  end

  def handle_info(:process_file, _) do
    Duper.PathFinder.next_path()
    |> add_result()
  end

  defp add_result(nil) do
    Duper.Gatherer.done()
    { :stop, :normal, nil }
  end

  defp add_result(path) do
    Duper.Gatherer.add_result(hash(path), path)
    send(self(), :process_file)
    { :noreply, nil }
  end

  defp hash(path) do
    File.stream!(path, [], 1024 * 1024)
    |> Enum.reduce(
      :crypto.hash_init(:md5),
      fn (block, hash) ->
        :crypto.hash_update(hash, block)
      end)
    |> :crypto.hash_final()
  end
end
