use Mix.Config

config :facebook_messenger,
  facebook_page_token: System.get_env("ACCESS_TOKEN"),
  challenge_verification_token: System.get_env("VERIFY_TOKEN")

config :dornbirnfurtbot, broadcaster: Dornbirnfurtbot.FacebookBroadcast
