defmodule Dornbirnfurtbot do
  require Logger

  @moduledoc """
  Documentation for Dornbirnfurtbot.
  """

  @doc """
  Start the bot app as a new application

  ## Examples

      iex> {:ok, pid} = Dornbirnfurtbot.start(1, 2)
      iex>  = is_pid(pid)
      iex> true == pid_returned
      true

  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    envport = System.get_env("PORT") || 5001

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
