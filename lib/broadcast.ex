defmodule Dornbirnfurtbot.Broadcast do
  @callback broadcast(String.t()) :: {:ok, term} | {:error, term}
end
