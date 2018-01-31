defmodule DornbirnfurtbotTest do
  use ExUnit.Case
  doctest Dornbirnfurtbot

  test "greets the world" do
    assert Dornbirnfurtbot.hello() == :world
  end
end
