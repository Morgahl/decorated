defmodule Decorated.Mock.GenServer do
  @required_callbacks [init: 1, terminate: 2]
  @debug_callbacks [handle_continue: 2, handle_call: 3, handle_cast: 2, handle_info: 2]

  defmacro __using__(opts) do
    hooks = Keyword.get(opts, :hooks, [])
    debug = hooks[:debug_hooks]
    exception = hooks[:exception_hooks]

    required_hooks = for {name, arity} <- @required_callbacks, do: start_stop_hooks(name, arity, :info)
    debug_hooks = for {name, arity} <- debug_callbacks(debug), do: start_stop_hooks(name, arity, :debug)
    exception_hooks = for {name, arity} <- exception_callbacks(exception, debug), do: exception_hook(name, arity)

    quote do
      use GenServer
      use Decorated.LifecycleHook, behaviour: GenServer
      require Logger

      unquote_splicing(required_hooks)
      unquote_splicing(debug_hooks)
      unquote_splicing(exception_hooks)
    end
  end

  defp debug_callbacks(true), do: @debug_callbacks
  defp debug_callbacks(_debug), do: []

  defp exception_callbacks(true, true), do: @required_callbacks ++ @debug_callbacks
  defp exception_callbacks(true, _debug), do: @required_callbacks
  defp exception_callbacks(_exception, _debug), do: []

  defp start_stop_hooks(name, arity, level) do
    args = Macro.generate_arguments(arity, __MODULE__)
    start_hook = :"#{name}_start"
    stop_hook = :"#{name}_stop"

    quote do
      def unquote(start_hook)(unquote_splicing(args)) do
        Logger.log(
          unquote(level),
          "#{inspect(__MODULE__)}.#{unquote(start_hook)}(#{Enum.map_join([unquote_splicing(args)], ", ", &inspect/1)})"
        )
      end

      def unquote(stop_hook)(result, start, unquote_splicing(args)) do
        Logger.log(
          unquote(level),
          "#{inspect(__MODULE__)}.#{unquote(stop_hook)}(#{Enum.map_join([result, start, unquote_splicing(args)], ", ", &inspect/1)})"
        )
      end
    end
  end

  defp exception_hook(name, arity) do
    args = Macro.generate_arguments(arity, __MODULE__)
    exception_hook = :"#{name}_exception"

    quote do
      def unquote(exception_hook)(exception, start, unquote_splicing(args)) do
        Logger.error(
          "#{inspect(__MODULE__)}.#{unquote(exception_hook)}(#{Enum.map_join([exception, start, unquote_splicing(args)], ", ", &inspect/1)})"
        )
      end
    end
  end
end
