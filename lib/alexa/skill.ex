defmodule Dornbirnfurtbot.Alexa.Skill do
  use Alexa.Skill, app_id: "dornbirn_furt"
  alias Dornbirnfurtbot.{Waterlevel, Router}

  def handle_intent("SayHello", request, response) do
    response
    |> say("Hello World!")
    |> Alexa.Response.should_end_session(true)
  end

  def handle_intent("Pegel", request, response) do
    level = Waterlevel.get(:waterlevel)
    response
    |> say("Der Pegel beträgt #{level} Zentimeter")
    |> Alexa.Response.should_end_session(true)
  end

  def handle_intent("Status", request, response) do
    level = Waterlevel.get(:waterlevel)
    gate_state = translate_state(Waterlevel.get(:gate_state))
    response
    |> say("Der Pegel beträgt #{level} Zentimeter, die Schranke ist #{gate_state}.")
    |> Alexa.Response.should_end_session(true)
  end

  def handle_intent("Schranke", request, response) do
    gate_state = translate_state(Waterlevel.get(:gate_state))
    response
    |> say("Die Schranke ist #{gate_state}")
    |> Alexa.Response.should_end_session(true)
  end

	defp translate_state(state) do
		case state do
			:open -> "offen"
			:closed  -> "geschlossen"
		end
	end
end
