defmodule Decorated.Logger do
  @moduledoc """
  A simple decorator that takes a message and logs the function name, arguments, and result of a function call.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details

  ## Example

      defmodule MyMath do
        use Decorated.Logger

        @decorate info_log(catch: :error)
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}

        @decorate debug_log(message: fn result -> "sub() -> %{result}" end)
        @spec sub(number(), number()) :: number()
        def sub(a, b), do: {:ok, a - b}

        @decorate warning_log(message: fn result -> "multiply() -> %{result}" end)
        @spec multiply(number(), number()) :: number()
        def multiply(a, b), do: {:ok, a * b}

        @decorate silent_log(catch: :error)
        @spec divide!(number(), number()) :: number()
        def divide!(_, 0), do: raise("do not divide by zero in MyMath functions")
        def divide!(a, b), do: a / b
      end

      iex> MyMath.add(1, 2)
      #> 23:14:44.410 [info] MyMath.add!(1, 2) ->
      {:ok, 3}

      iex> MyMath.sub(1, 2)
      #> 23:14:44.410 [debug] sub() -> -1
      {:ok, -1}

      iex> MyMath.multiply(1, 2)
      #> 23:14:44.410 [warning] multiply() -> 2
      {:ok, 2}

      iex> MyMath.divide!(4, 2)
      2.0

      iex> MyMath.divide!(4, 0)
      ** (RuntimeError) do not divide by zero in MyMath functions

      #> 23:14:44.410 [error] MyMath.divide!(4, 0) -> ** (RuntimeError) do not divide by zero in MyMath functions
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
    silent_log: 1

  import Decorated.Utilites.Compile

  alias Decorated.Logger.Opts

  debug_log_doc = """
  A decorator that produces a DEBUG level log using the `:message` when configured or a default message of:
    `Module.function(list, of , args) -> result`.
  The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """

  @doc debug_log_doc
  defmacro debug_log()

  @doc debug_log_doc
  defmacro debug_log(opts)

  @doc false
  @spec debug_log() :: no_return()
  @spec debug_log(Opts.options()) :: no_return()
  def debug_log(opts \\ [], body, ctx), do: log(:debug, opts, body, ctx)

  info_log_doc = """
  A decorator that produces an INFO level log using the `:message` when configured or a default message of:
    `Module.function(list, of , args) -> result`.
  The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """

  @doc info_log_doc
  defmacro info_log()

  @doc info_log_doc
  defmacro info_log(opts)

  @doc false
  @spec info_log() :: no_return()
  @spec info_log(Opts.options()) :: no_return()
  def info_log(opts \\ [], body, ctx), do: log(:info, opts, body, ctx)

  notice_log_doc = """
  A decorator that produces a NOTICE level log using the `:message` when configured or a default message of:
    `Module.function(list, of , args) -> result`.
  The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """

  @doc notice_log_doc
  defmacro notice_log()

  @doc notice_log_doc
  defmacro notice_log(opts)

  @doc false
  @spec notice_log() :: no_return()
  @spec notice_log(Opts.options()) :: no_return()
  def notice_log(opts \\ [], body, ctx), do: log(:notice, opts, body, ctx)

  warning_log_doc = """
  A decorator that produces a WARNING level log using the `:message` when configured or a default message of:
    `Module.function(list, of , args) -> result`.
  The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """

  @doc warning_log_doc
  defmacro warning_log()

  @doc warning_log_doc
  defmacro warning_log(opts)

  @doc false
  @spec warning_log() :: no_return()
  @spec warning_log(Opts.options()) :: no_return()
  def warning_log(opts \\ [], body, ctx), do: log(:warning, opts, body, ctx)

  error_log_doc = """
  A decorator that produces a ERROR level log using the `:message` when configured or a default message of:
    `Module.function(list, of , args) -> result`.
  The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """

  @doc error_log_doc
  defmacro error_log()

  @doc error_log_doc
  defmacro error_log(opts)

  @doc false
  @spec error_log() :: no_return()
  @spec error_log(Opts.options()) :: no_return()
  def error_log(opts \\ [], body, ctx), do: log(:error, opts, body, ctx)

  critical_log_doc = """
  A decorator that produces a CRITICAL level log using the `:message` when configured or a default message of:
    `Module.function(list, of , args) -> result`.
  The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """

  @doc critical_log_doc
  defmacro critical_log()

  @doc critical_log_doc
  defmacro critical_log(opts)

  @doc false
  @spec critical_log() :: no_return()
  @spec critical_log(Opts.options()) :: no_return()
  def critical_log(opts \\ [], body, ctx), do: log(:critical, opts, body, ctx)

  alert_log_doc = """
  A decorator that produces a ALERT level log using the `:message` when configured or a default message of:
    `Module.function(list, of , args) -> result`.
  The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """

  @doc alert_log_doc
  defmacro alert_log()

  @doc alert_log_doc
  defmacro alert_log(opts)

  @doc false
  @spec alert_log() :: no_return()
  @spec alert_log(Opts.options()) :: no_return()
  def alert_log(opts \\ [], body, ctx), do: log(:alert, opts, body, ctx)

  emergency_log_doc = """
  A decorator that produces a EMERGENCY level log using the `:message` when configured or a default message of:
    `Module.function(list, of , args) -> result`.
  The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """

  @doc emergency_log_doc
  defmacro emergency_log()

  @doc emergency_log_doc
  defmacro emergency_log(opts)

  @doc false
  @spec emergency_log() :: no_return()
  @spec emergency_log(Opts.options()) :: no_return()
  def emergency_log(opts \\ [], body, ctx), do: log(:emergency, opts, body, ctx)

  @doc """
  A decorator that produces no log UNLESS a configuration is provided in which case it produces a log at the provided
  level using the provided message.. The message has access to the named bindings of the decorated function's arguments.

  ## Options

  Please refer to `Decorated.Logger.Opts` for full details
  """
  defmacro silent_log(opts)

  @doc false
  @spec silent_log(Opts.options()) :: no_return()
  def silent_log(opts, body, ctx) when is_list(opts), do: log(:silent, opts, body, ctx)

  @doc false
  defmacro silent(_msg \\ nil, _ctx \\ nil), do: nil

  @doc false
  def stringify_args(args) do
    Enum.map_join(args, ", ", fn
      {:ignored, ignored} -> ignored
      arg -> inspect(arg, limit: :infinity, trim: :infinity)
    end)
  end

  defp build_logger_imports(log_level, %Opts{none_level: none_level, error_level: error_level, catch_level: catch_level}) do
    logger_imports =
      for level <- [log_level, none_level, error_level, catch_level],
          level != :silent,
          uniq: true,
          do: {level, 2}

    silent_import = if log_level == :silent, do: [silent: 2], else: []

    {logger_imports, silent_import}
  end

  defp ctx_drop_or_rename_args(ctx, ignored_behaviour) do
    ctx
    |> Map.update!(:args, &drop_or_rename_args(&1, ignored_behaviour))
    |> Map.from_struct()
  end

  defp drop_or_rename_args(args, :keep), do: args

  defp drop_or_rename_args(args, ignored_behaviour) do
    Enum.flat_map(args, &drop_or_rename_arg(&1, ignored_behaviour))
  end

  defp drop_or_rename_arg({name, _, _} = arg, :drop) do
    case Atom.to_string(name) do
      <<"_", _::binary>> -> []
      _ -> [arg]
    end
  end

  defp drop_or_rename_arg({name, _, _} = arg, :rename) do
    case Atom.to_string(name) do
      <<"_", _::binary>> = ignored -> [{:ignored, ignored}]
      _ -> [arg]
    end
  end

  defp drop_or_rename_arg(arg, _ignored_behaviour), do: [arg]

  defguardp is_valid_message?(message) when is_binary(message) or (is_tuple(message) and elem(message, 0) == :<<>>)

  defp log(log_level, opts, body, ctx) do
    opts = Opts.build!(log_level, opts, ctx)
    {logger_imports, silent_import} = build_logger_imports(log_level, opts)
    ctx = ctx_drop_or_rename_args(ctx, opts.ignored)

    case opts.message do
      nil ->
        log_msg_nil(log_level, opts, {logger_imports, silent_import}, body, ctx)

      message when is_valid_message?(message) ->
        log_msg_string(log_level, opts, {logger_imports, silent_import}, body, ctx, message)

      message_fn ->
        case get_ast_function_arity!(message_fn) do
          1 -> log_msg_func_1(log_level, opts, {logger_imports, silent_import}, body, ctx, message_fn)
          2 -> log_msg_func_2(log_level, opts, {logger_imports, silent_import}, body, ctx, message_fn)
          _ -> raise_error("The message function must be arity of 1 or 2", file: ctx.file, line: get_ast_line_location!(message_fn))
        end
    end
  end

  defp log_msg_nil(log_level, opts, {logger_imports, silent_import}, body, ctx) do
    mf_prefix = "#{inspect(ctx.module)}.#{Atom.to_string(ctx.name)}"

    quote generated: true do
      import Logger, only: [unquote_splicing(logger_imports)]
      import Decorated.Logger, only: [unquote_splicing(silent_import)]
      metadata = unquote(opts.metadata)

      try do
        result = unquote(body)
        message = "#{unquote(mf_prefix)}(#{Decorated.Logger.stringify_args(unquote(ctx.args))}) -> #{inspect(result)}"
        metadata = [{:result, result} | metadata]

        case result do
          :none -> unquote(opts.none_level)(message, metadata)
          :error -> unquote(opts.error_level)(message, metadata)
          {:error, _} -> unquote(opts.error_level)(message, metadata)
          _ -> unquote(log_level)(message, metadata)
        end

        result
      catch
        kind, caught ->
          message = "#{unquote(mf_prefix)}(#{Decorated.Logger.stringify_args(unquote(ctx.args))}) -> #{Exception.format(kind, caught)}"
          metadata = [{:kind, kind} | [{:caught, caught} | metadata]]
          unquote(opts.catch_level)(message, metadata)

          case kind do
            :error -> reraise caught, __STACKTRACE__
            _ -> reraise kind, caught, __STACKTRACE__
          end
      end
    end
  end

  defp log_msg_string(log_level, opts, {logger_imports, silent_import}, body, _ctx, message) do
    quote generated: true do
      import Logger, only: [unquote_splicing(logger_imports)]
      import Decorated.Logger, only: [unquote_splicing(silent_import)]
      metadata = unquote(opts.metadata)

      try do
        result = unquote(body)
        message = unquote(message)
        metadata = [{:result, result} | metadata]

        case result do
          :none -> unquote(opts.none_level)(message, metadata)
          :error -> unquote(opts.error_level)(message, metadata)
          {:error, _} -> unquote(opts.error_level)(message, metadata)
          _ -> unquote(log_level)(message, metadata)
        end

        result
      catch
        kind, caught ->
          message = unquote(message)
          metadata = [{:kind, kind} | [{:caught, caught} | metadata]]
          unquote(opts.catch_level)(message, metadata)

          case kind do
            :error -> reraise caught, __STACKTRACE__
            _ -> reraise kind, caught, __STACKTRACE__
          end
      end
    end
  end

  defp log_msg_func_1(log_level, opts, {logger_imports, silent_import}, body, _ctx, message) do
    quote generated: true do
      import Logger, only: [unquote_splicing(logger_imports)]
      import Decorated.Logger, only: [unquote_splicing(silent_import)]
      metadata = unquote(opts.metadata)

      try do
        result = unquote(body)
        message = unquote(message).(result)
        metadata = [{:result, result} | metadata]

        case result do
          :none -> unquote(opts.none_level)(message, metadata)
          :error -> unquote(opts.error_level)(message, metadata)
          {:error, _} -> unquote(opts.error_level)(message, metadata)
          _ -> unquote(log_level)(message, metadata)
        end

        result
      catch
        kind, caught ->
          message = unquote(message).({kind, caught})
          metadata = [{:kind, kind} | [{:caught, caught} | metadata]]
          unquote(opts.catch_level)(message, metadata)

          case kind do
            :error -> reraise caught, __STACKTRACE__
            _ -> reraise kind, caught, __STACKTRACE__
          end
      end
    end
  end

  defp log_msg_func_2(log_level, opts, {logger_imports, silent_import}, body, ctx, message) do
    quote generated: true do
      import Logger, only: [unquote_splicing(logger_imports)]
      import Decorated.Logger, only: [unquote_splicing(silent_import)]
      metadata = unquote(opts.metadata)

      ctx = unquote(ctx)

      try do
        result = unquote(body)
        message = unquote(message).(result, ctx)
        metadata = [{:result, result} | metadata]

        case result do
          :none -> unquote(opts.none_level)(message, metadata)
          :error -> unquote(opts.error_level)(message, metadata)
          {:error, _} -> unquote(opts.error_level)(message, metadata)
          _ -> unquote(log_level)(message, metadata)
        end

        result
      catch
        kind, caught ->
          message = unquote(message).({kind, caught}, ctx)
          metadata = [{:kind, kind} | [{:caught, caught} | metadata]]
          unquote(opts.catch_level)(message, metadata)

          case kind do
            :error -> reraise caught, __STACKTRACE__
            _ -> reraise kind, caught, __STACKTRACE__
          end
      end
    end
  end
end
