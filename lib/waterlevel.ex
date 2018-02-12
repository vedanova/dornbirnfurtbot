defmodule Dornbirnfurtbot.Waterlevel do
  require IEx
  use GenServer
  alias __MODULE__
  require Logger

  @broadcaster Application.fetch_env!(:dornbirnfurtbot, :broadcaster)

  defstruct waterlevel: 0,
            state: :initialized

  # level guards
  defguard alert_level(height) when height >= 3.5
  defguard warn_level(height) when height < 3.5 and height >= 3.0
  defguard below_warn_level(height) when height < 3.0
  # gate state guards
  defguard is_closed(new_state) when new_state <= 0
  defguard is_open(new_state) when new_state > 0

  def new(), do: %Waterlevel{}

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def init(_arg) do
    # gate: 1 open, 0 closed
    {:ok, %{waterlevel: 0, state: :initialized, gate_state: :open}}
  end

  def new_height(height) do
    GenServer.call(__MODULE__, {:new_height, height})
  end

  # return a particular key
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def handle_call({:get, key}, _from, state_data) do
    {:reply, state_data[key], state_data}
  end

  # ------ level states

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

  # ------ level states

  # ------ gate states

  def new_gate_state(gate_state) do
    GenServer.call(__MODULE__, {:gate_state, gate_state})
  end

  def handle_call({:gate_state, gate_state}, _from, state_data) do
    state_data
    |> check_gate(gate_state)
    |> reply_success(:ok)
  end

  def handle_call({:gate_state, gate_state}, _from, state_data) do
    state_data
    |> check_gate(gate_state)
    |> reply_success(:ok)
  end

  # gate changes to closed
  def check_gate(%{gate_state: :open} = state_data, new_state) when is_closed(new_state) do
    %{state_data | gate_state: :closed}
    message = "Die Schranke wurde geschlossen!"
    Logger.info("Broadcasting #{message}")
    @broadcaster.broadcast(message, "REGULAR")
    %{state_data | gate_state: :closed}
  end

  # gate changes to closed
  def check_gate(%{gate_state: :closed} = state_data, new_state) when is_open(new_state) do
    %{state_data | gate_state: :open}
    message = "Die Schranke ist wieder offen!"
    Logger.info("Broadcasting #{message}")
    @broadcaster.broadcast(message, "REGULAR")
    %{state_data | gate_state: :open}
  end

  def check_gate(state_data, new_state) do
    Logger.info("Ignoring gate state #{new_state} as it didn't change")
    state_data
  end

  # ------ gate states

  defp reply_success(state_data, reply), do: {:reply, reply, state_data}
end
