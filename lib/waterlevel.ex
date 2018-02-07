defmodule Dornbirnfurtbot.Waterlevel do
  require IEx
  use GenServer
  alias __MODULE__

  @broadcaster Application.fetch_env!(:dornbirnfurtbot, :broadcaster)

  defstruct waterlevel: 0,
            state: :initialized

  defguard alert_level(height) when height >= 3.5
  defguard warn_level(height) when height < 3.5 and height >= 3.0
  defguard below_warn_level(height) when height < 3.0

  def new(), do: %Waterlevel{}

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def init(_arg) do
    {:ok, %{waterlevel: 0, state: :initialized}}
  end

  def new_height(height) do
    GenServer.call(__MODULE__, {:new_height, height})
  end

  def handle_call({:new_height, height}, _from, state_data) do
    state_data
    |> check(height)
    |> reply_success(:ok)
  end

  # flodded && alarm sent already
  def check(%{state: :flodded} = state_data, height) when alert_level(height) do
    %{state_data | state: :flodded, waterlevel: height}
  end

  # flodded
  def check(%{state: :warned} = state_data, height) when alert_level(height) do
    message = "Die Furt ist gesperrt. Höhe: #{inspect(height)}"
    @broadcaster.broadcast(message, "REGULAR")
    %{state_data | state: :flodded, waterlevel: height}
  end

  # warned, already sent
  def check(%{state: :warned} = state_data, height) when warn_level(height) do
    %{state_data | state: :warned, waterlevel: height}
  end

  # flodded, returns back to warn level to not alarm twice
  def check(%{state: :flodded} = state_data, height) when warn_level(height) do
    message = "Die Furt wird wahrscheinlich bald wieder offen sein. Höhe: #{inspect(height)}"
    @broadcaster.broadcast(message, "REGULAR")
    %{state_data | state: :level_drop, waterlevel: height}
  end

  # drop of waterlevel back to normal
  def check(%{state: :level_drop} = state_data, height) when warn_level(height) do
    %{state_data | state: :level_drop, waterlevel: height}
  end

  # notify soon flodded
  def check(%{state: :normal} = state_data, height) when warn_level(height) do
    message = "Die Furt wird vielleicht bald geschlossen sein"
    @broadcaster.broadcast(message, "REGULAR")
    %{state_data | state: :warned, waterlevel: height}
  end

  # normal level
  def check(%{state: _} = state_data, height) do
    %{state_data | state: :normal, waterlevel: height}
  end

  defp reply_success(state_data, reply), do: {:reply, reply, state_data}
end
