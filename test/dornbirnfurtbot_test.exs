defmodule DornbirnfurtbotTest do
  use ExUnit.Case
  #  doctest Dornbirnfurtbot

  test "starts a new process" do
    {:ok, pid} = Dornbirnfurtbot.start()
    assert is_pid(pid)
  end
end
