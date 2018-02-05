defmodule Dornbirnfurtbot.Broadcast do
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> Dornbirnfurtbot.Broadcast.broadcast "Test broadcast"
      {:ok, {:create, "shopping"}}

  """
  def broadcast(message, notification_type \\ "NO_PUSH") do
    FacebookMessenger.Sender.text_broadcast(message, "TRANSPORTATION_UPDATE", notification_type)
  end
end
