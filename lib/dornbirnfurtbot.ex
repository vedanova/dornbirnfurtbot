defmodule Dornbirnfurtbot do
  require Logger

  @moduledoc """
  Documentation for Dornbirnfurtbot.
  """

  @doc """
  Start the bot app as a new application

  ## Examples

      iex> {:ok, pid} = Dornbirnfurtbot.start

  """
  def start() do
    import Supervisor.Spec, warn: false

    envport = System.get_env("PORT") || 5002

    port =
      case envport do
        envport when is_binary(envport) -> envport |> String.to_integer()
        _ -> envport
      end

    Logger.info("Started application")
    Logger.info("Port assigned to #{port}")

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Dornbirnfurtbot.Router, [], port: port),
      worker(Dornbirnfurtbot.Waterlevel, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
