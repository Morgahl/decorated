import Config

config :logger,
  backends: [:console]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: :all
