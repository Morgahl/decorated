defmodule Decorated.Logger.Opts do
  @moduledoc """
  A module that defines the configurations options for the `Decorated.Logger` decorator.

  ## Option

  * `:message` - `message_opt()` - The message to log. This can be a string, a binary, or an IO list.
  * `:none` - `log_level()` - The log level to use when the decorated function returns `:none`. Defaults to the same level as the decorating log level.
  * `:error` - `log_level()` - The log level to use when the decorated function returns `:error` or `{:error, _}`. Defaults to the same level as the decorating log level.
  * `:catch` - `log_level()` - The log level to use when the decorated function raises an `Exception.kind()`. Defaults to the same level as the decorating log level.
  * `:ignored` - `ignore_behaviour()` - The behaviour to use when the decorated function has an ignored argument ex. `_` or `_ignored`.
    Defaults to `:rename`.
    * `:drop` - Drop the ignored argument from the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(:ok)`
    * `:rename` - Rename the ignored argument in the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(_, _a, :ok)`
    * `:keep` - Keep the ignored argument in the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(nil, nil, :ok)`
  * `:metadata` - `Keyword.t()` - The metadata to include in the log message. Injects the `:line` metadata by default.

  ## Example

      defmodule MyMath do
        use Decorated.Logger

        @decorate info_log(catch: :error)
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}

        @decorate debug_log(error: :critical)
        @spec sub(number(), number()) :: number()
        def sub(a, b), do: {:ok, a - b}

        @decorate critical_log(message: fn result -> "multiply() -> %{result}" end)
        @spec multiply(number(), number()) :: number()
        def multiply(a, b), do: {:ok, a * b}
      end

      iex> MyMath.add(1, 2)
      #> 23:14:44.410 [info] MyMath.add!(1, 2) -> {:ok, 3}
      {:ok, 3}

      iex> MyMath.sub(1, 2)
      #> 23:14:44.410 [debug] sub() -> -1
      {:ok, -1}

      iex> MyMath.multiply(1, 2)
      #> 23:14:44.410 [critical] multiply() -> 2
      {:ok, 2}
  """
  import Decorated.Utilites.Compile

  alias Decorator.Decorate.Context

  @levels [
    :silent,
    :debug,
    :info,
    :notice,
    :warning,
    :error,
    :critical,
    :alert,
    :emergency
  ]

  @keys [:message, :none_level, :error_level, :catch_level, :ignored, :metadata]

  @optional_keys [:message, :metadata]

  @ignore_behaviours [
    :drop,
    :rename,
    :keep
  ]

  @typedoc """
  The log level to use for a given configuration.

  In addition to the standard log levels provided by `Logger`, the following log levels are also supported:
  * `:silent` - Do not log the decorated function.
  """
  @type level() ::
          :silent
          | Logger.level()

  @type message_opt() :: {:message, String.t() | (any() -> String.t()) | (any(), Context.t() -> String.t())}

  @typedoc """
  The log level configuration, message, and metadata, and log level overides for common divergent scenarios.

  ## Option

  * `:message` - `message_opt()` - The message to log. This can be a string, a binary, or an IO list.
  * `:none` - `log_level()` - The log level to use when the decorated function returns `:none`. Defaults to the same level as the decorating log level.
  * `:error` - `log_level()` - The log level to use when the decorated function returns `:error` or `{:error, _}`. Defaults to the same level as the decorating log level.
  * `:catch` - `log_level()` - The log level to use when the decorated function raises an `Exception.kind()`. Defaults to the same level as the decorating log level.
  * `:ignored` - `ignore_behaviour()` - The behaviour to use when the decorated function has an ignored argument ex. `_` or `_ignored`. Defaults to `:rename`.
    * `:drop` - Drop the ignored argument from the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(:ok)`
    * `:rename` - Rename the ignored argument in the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(_, _a, :ok)`
    * `:keep` - Keep the ignored argument in the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(nil, nil, :ok)`
  * `:metadata` - `Keyword.t()` - The metadata to include in the log message. Injects the `:line` metadata by default.
  """
  @type log_opt() ::
          message_opt()
          | {:none, level()}
          | {:error, level()}
          | {:catch, level()}
          | {:ignored, ignore_behaviour()}
          | {:metadata, Keyword.t()}

  @typedoc """
  The ignore behaviour to use for a given configuration.

  * `:drop` - Drop the ignored argument from the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(:ok)`
  * `:rename` - Rename the ignored argument in the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(_, _a, :ok)`
  * `:keep` - Keep the ignored argument in the log message. `foo(_, _a, bar)(nil, nil, :ok)` => `foo(nil, nil, :ok)`
  """
  @type ignore_behaviour() ::
          :drop
          | :rename
          | :keep

  @enforce_keys Enum.reject(@keys, &(&1 in @optional_keys))
  defstruct @keys

  defguardp valid_message?(message) when is_nil(message) or is_binary(message) or (is_tuple(message) and elem(message, 0) == :<<>>)

  @doc """
  Builds a `Decorated.Logger.Opts` struct from the given options.
  """
  def build!(level, opts, %Context{} = ctx) when level in @levels do
    with msg when valid_message?(msg) <- Keyword.get(opts, :message),
         none_level when none_level in @levels <- Keyword.get(opts, :none, level),
         error_level when error_level in @levels <- Keyword.get(opts, :error, level),
         catch_level when catch_level in @levels <- Keyword.get(opts, :catch, level),
         ignored_behaviour when ignored_behaviour in @ignore_behaviours <- Keyword.get(opts, :ignored, :rename),
         metadata when is_list(metadata) <- Keyword.get(opts, :metadata, line: ctx.line) do
      %__MODULE__{
        message: msg,
        none_level: none_level,
        error_level: error_level,
        catch_level: catch_level,
        ignored: ignored_behaviour,
        metadata: metadata |> Keyword.put_new(:line, ctx.line)
      }
    else
      {opt, value} -> raise_error("invalid log option #{inspect(opt)} with value #{inspect(value)}", file: ctx.file, line: ctx.line)
    end
  end
end
