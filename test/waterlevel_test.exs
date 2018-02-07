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

  describe "state :warned" do
    test "from :warned to :flodded" do
      state_data = Waterlevel.check(%{state: :warned, waterlevel: 0}, 4)
      assert state_data[:state] == :flodded
    end
  end

  describe "state :flodded" do
    test "from :flodded to :level_drop" do
      state_data = Waterlevel.check(%{state: :flodded, waterlevel: 4}, 3.1)
      assert state_data[:state] == :level_drop
    end
  end

  describe "state :level_drop" do
    test "from :level_drop to :normal" do
      state_data = Waterlevel.check(%{state: :level_drop, waterlevel: 4}, 1)
      assert state_data[:state] == :normal
    end
  end
end
