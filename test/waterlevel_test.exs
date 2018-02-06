defmodule Dornbirnfurtbot.WaterlevelTest do
  use ExUnit.Case
  alias Dornbirnfurtbot.{Waterlevel}

  setup_all do
    %{waterlevel: Waterlevel.new()}
  end

  test "initializes with default values", state do
    %{waterlevel: wl, state: st} = state.waterlevel
    assert wl == 0
    assert st == :initialized
  end

  test "from initialized to normal" do
    state_data = Waterlevel.check(%{state: :initialized, waterlevel: 0}, 1)
    assert state_data[:state] == :normal
  end

  describe "state :normal" do
    test "from :normal to :warned" do
      state_data = Waterlevel.check(%{state: :normal, waterlevel: 0}, 3.1)
      assert state_data[:state] == :warned
    end
  end
end
