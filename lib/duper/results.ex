defmodule Duper.Results do
  use GenServer

  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, :no_args, name: @me)
  end

  def add(hash, path) do
    GenServer.cast(@me, { :add, hash, path})
  end

  def find_duplicates() do
    GenServer.call(@me, :find_duplicates)
  end

  # GenServer implementation

  def init(:no_args) do
    { :ok, %{} }
  end

  def handle_cast({ :add, hash, path }, results) do
    results = Map.update(results, hash, [path], fn existing -> [path | existing] end)
    { :noreply, results}
  end

  def handle_call(:find_duplicates, _from, results) do
    { :reply, find_dups(results), results }
  end

  defp find_dups(results) do
    results
    |> Enum.filter(fn { _hash, pathes } -> length(pathes) > 1 end)
    |> Enum.map(fn { _hash, pathes } -> pathes end)
  end
end
