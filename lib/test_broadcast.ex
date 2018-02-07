defmodule Dornbirnfurtbot.TestBroadcast do
  @behaviour Dornbirnfurtbot.Broadcast

  @doc ~S"""
  Test module for mocking broadcast requests

  """
  def broadcast(_message, _notification_type \\ "NO_PUSH") do
    {:ok, %{broadcast_id: 999}}
  end
end
