defmodule Dornbirnfurtbot.Router do
  alias Dornbirnfurtbot.{Waterlevel, Router}
  require Logger
  import Plug.Conn
  use Plug.Router
  plug Plug.Static,
    at: "/",
    from: :dornbirnfurtbot

  plug(Plug.Logger, log: :debug)

  plug(
    Plug.Parsers,
    parsers: [:json],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  forward(
    "/webhook",
    to: FacebookMessenger.Router,
    message_received: &Router.message/1
  )

  post "/alexa/command" do
    {:ok, data} = Poison.encode(conn.body_params)
    request = Poison.decode!(data, as: %Alexa.Request{})

    # this would work with poison > 3, but cannot upgrade
    # opts = %{as: %Alexa.Request{}}; 
    # request = conn.body_params |> Poison.Decoder.transform(opts) |> Poison.Decoder.decode(opts)

    response = Alexa.handle_request(request)
    conn = send_resp(conn, 200, Poison.encode!(response))
    conn = %{conn | resp_headers: [{"content-type", "application/json"}]}
    conn
  end

  # TTN Payload
  # %{"app_id" => "citymonitor", "counter" => 32, "dev_id" => "furt_pegel",
  # "downlink_url" => "https://integrations.thethingsnetwork.org/ttn-eu/api/v2/down/citymonitor/furt_bot_hook?key=ttn-account-v2.AluPspgSKXmpvKmWDYbgXDD1IrUUKiDbqvmlnq0Tc4Q", "hardware_serial" => "00D5F9475ACE563A", "metadata" => %{"coding_rate" => "4/5", "data_rate" => "SF7BW125", "frequency" => 867.9, "gateways" => [%{"channel" => 7, "gtw_id" => "eui-9d4004f0211748e3", "rf_chain" => 0, "rssi" => -119, "snr" => -3, "time" => "2018-01-14T21:30:06.123698Z", "timestamp" => 782921484}],
  # "modulation" => "LORA", "time" => "2018-01-14T21:30:06.163355109Z"},
  # "payload_raw" => "AAU=", "port" => 1}
  #
  #   "AAY=" |> Base.decode64! |> :binary.decode_unsigned
  post "/broadcast" do
    process(conn.body_params)
    send_resp(conn, 200, "Sent message")
  end

  match(_, do: send_resp(conn, 200, "error"))

  def message(msg) do
    text =
      FacebookMessenger.Response.message_texts(msg)
      |> hd

    sender =
      FacebookMessenger.Response.message_senders(msg)
      |> hd

    Logger.info(sender)
    FacebookMessenger.Sender.send(sender, text)
    send(self(), 3)
  end

  @doc "decode payload when payload is an unsigned integer"
  defp decode_payload(data) do
    data
    |> Base.decode64!()
    |> :binary.decode_unsigned()
  end

  # ---------- device processors

  defp process(%{"dev_id" => "furt_pegel"} = params) do
    %{"payload_raw" => payload} = params

    payload
    |> decode_payload
    |> Waterlevel.new_height()
  end

  defp process(%{"dev_id" => "furt_schranke"} = params) do
    %{"payload_raw" => payload} = params

    payload
    |> decode_payload
    |> Waterlevel.new_gate_state()
  end

  defp process(payload) do
    Logger.info("Unhandled payload: #{inspect(payload)}")
  end
end
