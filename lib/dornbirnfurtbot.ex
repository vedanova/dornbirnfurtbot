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
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port =
      case System.get_env("PORT") do
        port when is_binary(port) -> port |> String.to_integer()
        _ -> 5002
      end

    Logger.info("Started application")
    Logger.info("Port assigned to #{port}")

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Dornbirnfurtbot.Router, [], port: port),
      worker(Dornbirnfurtbot.Waterlevel, []),
      worker(Dornbirnfurtbot.Alexa.Skill, [[app_id: "dornbirn_furt"]]),

    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
