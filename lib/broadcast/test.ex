defmodule Dornbirnfurtbot.Broadcast.Test do
  @behaviour Dornbirnfurtbot.Broadcast

  @doc ~S"""
  Test module for mocking broadcast requests

  """
  @spec broadcast(String.t(), String.t()) :: {:ok, %{broadcast_id: number}}
  def broadcast(_message, _notification_type \\ "NO_PUSH") do
    {:ok, %{broadcast_id: 999}}
  end
end
