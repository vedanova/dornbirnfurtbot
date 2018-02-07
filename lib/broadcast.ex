defmodule Dornbirnfurtbot.Broadcast do
  @doc """
    Broadcasts a message and returns a tuple either ok or error
    depending on success or failure
  """
  @callback broadcast(String.t, String.t) ::
              {:ok, %{broadcast_id: number}} | {:error, term}

end
