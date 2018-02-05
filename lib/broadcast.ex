defmodule Dornbirnfurtbot.Broadcast do
  @doc ~S"""
  Sends out message to broadcast receivers

  ## Examples
  
      iex> Dornbirnfurtbot.Broadcast.broadcast "Test broadcast"
  """
  def broadcast(message, notification_type \\ "NO_PUSH") do
    FacebookMessenger.Sender.text_broadcast(message, "TRANSPORTATION_UPDATE", notification_type)
  end
end
