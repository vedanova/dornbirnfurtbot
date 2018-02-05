defmodule Dornbirnfurtbot.Router do
  alias Dornbirnfurtbot.{Waterlevel}
  import Plug.Conn
  use Plug.Router
  require Logger

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Poison
  )

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  forward(
    "/webhook",
    to: FacebookMessenger.Router,
    message_received: &Dornbirnfurtbot.Router.message/1
  )

  # TTN Payload
  # %{"app_id" => "citymonitor", "counter" => 32, "dev_id" => "furt_pegel",
  #  "downlink_url" => "https://integrations.thethingsnetwork.org/ttn-eu/api/v2/down/citymonitor/furt_bot_hook?key=ttn-account-v2.AluPspgSKXmpvKmWDYbgXDD1IrUUKiDbqvmlnq0Tc4Q", "hardware_serial" => "00D5F9475ACE563A", "metadata" => %{"coding_rate" => "4/5", "data_rate" => "SF7BW125", "frequency" => 867.9, "gateways" => [%{"channel" => 7, "gtw_id" => "eui-9d4004f0211748e3", "rf_chain" => 0, "rssi" => -119, "snr" => -3, "time" => "2018-01-14T21:30:06.123698Z", "timestamp" => 782921484}],
  #  "modulation" => "LORA", "time" => "2018-01-14T21:30:06.163355109Z"},
  # "payload_raw" => "AAU=", "port" => 1}
  #
  #   "AAY=" |> Base.decode64! |> :binary.decode_unsigned
  post "/broadcast" do
    # get parameters
    conn = fetch_query_params(conn)
    payload = Map.get(conn.body_params, "payload_raw", 0)
    height = payload |> Base.decode64!() |> :binary.decode_unsigned()

    #    Broadcast.broadcast(height)
    Waterlevel.new_height(height)

    send_resp(conn, 200, "Sent message")
  end

  match(_, do: send_resp(conn, 500, "error"))

  def message(msg) do
    text = FacebookMessenger.Response.message_texts(msg) |> hd
    sender = FacebookMessenger.Response.message_senders(msg) |> hd
    Logger.info(sender)
    FacebookMessenger.Sender.send(sender, text)
    send(self(), 3)
  end
end
