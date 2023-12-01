import Config

valid_backends = [:console]

config :logger, backends: [:console]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: :all

case {config_env(), System.get_env("LOG_BACKENDS")} do
  {:test, backends} when is_binary(backends) ->
    config :logger,
      backends:
        backends
        |> String.downcase()
        |> String.split(",")
        |> Enum.map(&String.to_existing_atom/1)
        |> Enum.filter(&(&1 in valid_backends))

  {:test, _} ->
    config :logger, backends: []

  _ ->
    nil
end
