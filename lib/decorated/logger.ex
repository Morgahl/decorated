defmodule Decorated.Logger do
  @moduledoc """
  A simple decorator that takes a message and logs the function name, arguments, and result of a function call.
  """

  use Decorator.Define,
    debug_log: 0,
    debug_log: 1,
    info_log: 0,
    info_log: 1,
    notice_log: 0,
    notice_log: 1,
    warning_log: 0,
    warning_log: 1,
    error_log: 0,
    error_log: 1,
    critical_log: 0,
    critical_log: 1,
    alert_log: 0,
    alert_log: 1,
    emergency_log: 0,
    emergency_log: 1,
    silent_log: 0,
    silent_log: 1

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

  @ignore_behaviours [
    :drop,
    :rename,
    :keep
  ]

  @typedoc """
  The log level to use for a given configuration.
  """
  @type log_level() ::
          :silent
          | :debug
          | :info
          | :notice
          | :warning
          | :error
          | :critical
          | :alert
          | :emergency

  @type ignore_behaviour() ::
          :drop
          | :rename
          | :keep

  @typedoc """
  The log level configuration for a given common divergent scenarios.
  """
  @type log_opt() ::
          {:message, String.t()}
          | {:none, log_level()}
          | {:error, log_level()}
          | {:catch, log_level()}
          | {:ignored, ignore_behaviour()}

  @doc """
  A decorator that produces a DEBUG level log using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec debug_log() :: no_return()
  @spec debug_log([log_opt()]) :: no_return()
  def debug_log(opts \\ [], body, ctx), do: log(:debug, opts, body, ctx)

  @doc """
  A decorator that produces an INFO level log using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec info_log() :: no_return()
  @spec info_log([log_opt()]) :: no_return()
  def info_log(opts \\ [], body, ctx), do: log(:info, opts, body, ctx)

  @doc """
  A decorator that produces a NOTICE level log using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec notice_log() :: no_return()
  @spec notice_log([log_opt()]) :: no_return()
  def notice_log(opts \\ [], body, ctx), do: log(:notice, opts, body, ctx)

  @doc """
  A decorator that produces a WARNING level log using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec warning_log() :: no_return()
  @spec warning_log([log_opt()]) :: no_return()
  def warning_log(opts \\ [], body, ctx), do: log(:warning, opts, body, ctx)

  @doc """
  A decorator that produces a ERROR level log using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec error_log() :: no_return()
  @spec error_log([log_opt()]) :: no_return()
  def error_log(opts \\ [], body, ctx), do: log(:error, opts, body, ctx)

  @doc """
  A decorator that produces a CRITICAL level log using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec critical_log() :: no_return()
  @spec critical_log([log_opt()]) :: no_return()
  def critical_log(opts \\ [], body, ctx), do: log(:critical, opts, body, ctx)

  @doc """
  A decorator that produces a ALERT level log using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec alert_log() :: no_return()
  @spec alert_log([log_opt()]) :: no_return()
  def alert_log(opts \\ [], body, ctx), do: log(:alert, opts, body, ctx)

  @doc """
  A decorator that produces a EMERGENCY level log using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec emergency_log() :: no_return()
  @spec emergency_log([log_opt()]) :: no_return()
  def emergency_log(opts \\ [], body, ctx), do: log(:emergency, opts, body, ctx)

  @doc """
  A decorator that produces no log UNLESS a configuration is provided in which case it produces a log at the provided
  level using the provided message.

  The message has interpolated access to the function arguments by name defined in the imeadiately following function
  definition.
  """
  @spec silent_log() :: no_return()
  @spec silent_log([log_opt()]) :: no_return()
  def silent_log(opts \\ [], body, ctx), do: log(:silent, opts, body, ctx)

  defmacro silent(_msg \\ nil, _ctx \\ nil), do: nil

  def stringify_args(args) do
    args
    |> Enum.map_join(", ", fn
      {:atom, atom} when is_atom(atom) ->
        inspect(atom)

      atom when is_atom(atom) ->
        case Atom.to_string(atom) do
          "_" -> :_
          <<"_", _::binary>> = string -> "#" <> string
          binary -> binary
        end

      binary when is_binary(binary) ->
        binary

      arg ->
        inspect(arg)
    end)
  end

  defguardp valid_message?(message) when is_nil(message) or is_binary(message) or (is_tuple(message) and elem(message, 0) == :<<>>)

  defmacrop raise_compile_error(desc, ctx) do
    quote(do: raise(CompileError, description: unquote(desc), file: unquote(ctx).file, line: unquote(ctx).line))
  end

  defp build_log_opts!(log_level, opts, ctx) when log_level in @levels do
    with msg when valid_message?(msg) <- Keyword.get(opts, :message),
         none_level when none_level in @levels <- Keyword.get(opts, :none, log_level),
         error_level when error_level in @levels <- Keyword.get(opts, :error, log_level),
         catch_level when catch_level in @levels <- Keyword.get(opts, :catch, log_level),
         ignored_behaviour when ignored_behaviour in @ignore_behaviours <- Keyword.get(opts, :ignored, :rename) do
      {msg, none_level, error_level, catch_level, ignored_behaviour}
    else
      {opt, value} -> raise_compile_error("invalid log option #{inspect(opt)} with value #{inspect(value)}", ctx)
    end
  end

  defp build_logger_imports(log_level, none_level, error_level, catch_level)
       when log_level in @levels and none_level in @levels and error_level in @levels and catch_level in @levels do
    for level <- [log_level, none_level, error_level, catch_level],
        level != :silent,
        uniq: true,
        do: {level, 2}
  end

  defp ctx_drop_or_rename_args(ctx, ignored_behaviour) when ignored_behaviour in @ignore_behaviours do
    ctx
    |> Map.update!(:args, &drop_or_rename_args(&1, ignored_behaviour))
    |> Map.from_struct()
  end

  defp drop_or_rename_args(args, :keep), do: args

  defp drop_or_rename_args(args, ignored_behaviour) when ignored_behaviour in @ignore_behaviours do
    args
    |> Enum.flat_map(&drop_or_rename_arg(&1, ignored_behaviour))
  end

  defp drop_or_rename_arg(arg, ignored_behaviour) when ignored_behaviour in @ignore_behaviours do
    with {name, _, _} <- arg, <<"_", _::binary>> <- Atom.to_string(name) do
      case ignored_behaviour do
        :drop -> []
        :rename -> [name]
      end
    else
      atom when is_atom(atom) -> [{:atom, atom}]
      _ -> [arg]
    end
  end

  defp log(log_level, opts, body, ctx) when log_level in @levels do
    {msg, none_level, error_level, catch_level, ignored_behaviour} = build_log_opts!(log_level, opts, ctx)
    logger_imports = build_logger_imports(log_level, none_level, error_level, catch_level)
    ctx = ctx_drop_or_rename_args(ctx, ignored_behaviour)
    %{module: module, name: name, args: args} = ctx

    quote generated: true, location: :keep do
      import Logger, only: [unquote_splicing(logger_imports)]
      import Decorated.Logger, only: [silent: 2, stringify_args: 1]

      ctx = [unquote_splicing(Map.to_list(ctx))]

      try do
        result = unquote(body)

        message =
          unquote(msg) ||
            "#{unquote(inspect(module))}.#{unquote(Atom.to_string(name))}(#{stringify_args(unquote(args))}) -> #{inspect(result)}"

        ctx = [{:result, result} | ctx]

        case result do
          :none -> unquote(none_level)(message, ctx)
          :error -> unquote(error_level)(message, ctx)
          {:error, _} -> unquote(error_level)(message, ctx)
          _ -> unquote(log_level)(message, ctx)
        end

        result
      catch
        kind, caught ->
          message =
            unquote(msg) ||
              "#{unquote(inspect(module))}.#{unquote(Atom.to_string(name))}(#{stringify_args(unquote(args))}) -> #catch{kind: #{inspect(kind)}, caught: #{inspect(caught)}}"

          ctx = [{:caught, caught} | [{:kind, kind} | ctx]]

          unquote(catch_level)(message, ctx)

          reraise caught, __STACKTRACE__
      end
    end
  end
end
