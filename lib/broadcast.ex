defmodule Dornbirnfurtbot.Broadcast do
  @doc ~S"""
  Sends out message to broadcast receivers

  ## Examples

      iex> Dornbirnfurtbot.Broadcast.broadcast "Test broadcast"
  """
  @fb_api Application.fetch_env!(:dornbirnfurtbot, :broadcaster)

  defmodule Behaviour do
    @callback broadcast([key: String.t]) :: :ok
  end


  def broadcast(broadcaster \\ @fb_api, message, notification_type \\ "NO_PUSH") do
    @fb_api.text_broadcast(message, "TRANSPORTATION_UPDATE", notification_type)
  end
end
