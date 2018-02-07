defmodule Dornbirnfurtbot.FacebookBroadcast do
  @behaviour Dornbirnfurtbot.Broadcast

  @doc ~S"""
  Sends out message to broadcast receivers

  ## Examples

      iex> Dornbirnfurtbot.FacebookBroadcast.broadcast "Test broadcast"
  """
  def broadcast(message, notification_type \\ "NO_PUSH") do
    case FacebookMessenger.Sender.text_broadcast(
           message,
           "TRANSPORTATION_UPDATE",
           notification_type
         ) do
      %{body: body, status_code: 400} -> {:error, body |> Poison.decode!()}
      %{body: body, status_code: 200} -> {:ok, body |> Poison.decode!()}
    end
  end
end
