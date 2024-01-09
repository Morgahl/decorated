defmodule Decorated.LifecycleHook do
  @moduledoc """
  `#{inspect(__MODULE__)}` provides automatic wrapping of behaviour callback functions with optional `start`, `stop`,
  and `exception` hooks.

  ## Purpose

  `#{inspect(__MODULE__)}` simplifies the process of wrapping the behaviour callback functions with optional lifecycle
  hooks. It allows you to add custom logic before and after the execution of the callback functions, without changing
  the parameters, results, or exceptions raised; all while maintaining the original behaviour of the callback functions.
  When a module uses this hook, it automatically wraps the specified callbacks with corresponding `start`, `stop`, and
  `exception` functions if they are defined.

  ## Common Uses

  - **Logging**: Automatically log inputs, outputs, exceptions, or execution time of behaviour callbacks.
  - **Performance Monitoring**: Measure and record the execution time of critical callbacks.
  - **Exception Handling**: Capture exceptions raised during the execution of callbacks.

  ## Notes

  - **Scope**:

      - The module specifically targets functions defined as behaviour callbacks.
      - Only functions matching the behaviour's callbacks (specified via `@behaviour` attributes) are considered for
        hooking.
      - Functions not specified in the behaviour are not affected.

  - **Hook Definitions**:

      - Hooks must be defined in the same module where `#{inspect(__MODULE__)}` is used.
      - The `start` hook must have the same arity as the original function.
      - The `stop` and `exception` hooks must have an arity of the original function's arity plus two (2), to
        accommodate the `result` (or exception information) and the `start` data.
      - If no `start` hook is defined, the `start` data passed to the `stop` and `exception` hooks will be `nil`.

  - **Super Calls**:

      - The original function implementation is called using `Kernel.super/1`.
      - This is essential to maintain the original behaviour while adding hook functionality.

  - **Hook Availability**:

      - If none of the hooks (`start`, `stop`, `exception`) are defined for a function, it remains unwrapped.
      - !!! Hooks with misaligned arities will not be considered for wrapping and will be silently discarded.

  ## Defining Hooks

  Given a behaviour callback `foo/2`, you can define the following hooks:

  - **`foo_start/2`**:

      - Receives the same arguments as `:foo`.
      - Must have the same arity as `:foo` (2 in this case).

  - **`foo_stop/4`**:

      - Receives the result of `:foo`
      - Receives the `start` data (or `nil` if no `start` hook is defined).
      - Receives the arguments passed to `:foo`.

  - **`foo_exception/4`**:

      - Receives the exception

          - `{:error, reason, stacktrace}` for errors.
          - `{:exit, reason, stacktrace}` for exits.
          - `{:throw, thrown, stacktrace}` for throws.

        - Receives the `start` data (or `nil` if no `start` hook is defined).
        - Receives the arguments passed to `:foo`.

  ## Default Hooks

  If defined in the module, the following default hooks are used as a fallback if no specific hook is defined:

  - **`__default_start__/1`**:

      - Receives a tuple containing the module, function name, and arguments.
      - This is the default `start` hook if none is defined for a function.

  - **`__default_stop__/3`**:

      - Receives the result of the function, the `start` data, and the arguments.
      - This is the default `stop` hook if none is defined for a function.

  - **`__default_exception__/3`**:

        - Receives the exception information, the `start` data, and the arguments.
        - This is the default `exception` hook if none is defined for a function.

  ## Example Usage

  The following example demonstrates how to create a custom `GenServer` module that uses `#{inspect(__MODULE__)}` to add
  logging and exception handling to the `init/1` lifecycle callback:

      defmodule MyApp.GenServer do
        defmacro __using__(_opts) do
          quote do
            use GenServer
            use #{inspect(__MODULE__)}
            require Logger

            defmacrop init_start(args) do
              quote do
                Logger.info("Starting \#{inspect(__MODULE__)} with args: \#{inspect(unquote(args))}")
                monotonic_instant()
              end
            end

            defmacrop init_stop(result, start, _args) do
              quote do
                elapsed = monotonic_since(unquote(start))
                Logger.info("Started \#{inspect(__MODULE__)} with result: \#{inspect(unquote(result))}", took: elapsed)
              end
            end

            defmacrop init_exception(exception_info, start, _args) do
              quote do
                elapsed = monotonic_since(unquote(start))
                Logger.error("Exception in init: \#{inspect(unquote(exception_info))}", took: elapsed)
              end
            end

            def __default_start__({module, name, args}) do
              Logger.info("Calling \#{inspect(module)}.\#{name} with args: \#{inspect(args)}")
              monotonic_instant()
            end

            def __default_stop__(result, start, {module, name, _args}) do
              elapsed = monotonic_since(start)
              Logger.info("Called \#{inspect(module)}.\#{name} with result: \#{inspect(result)}", took: elapsed)
            end

            def __default_exception__(exception_info, start, {module, name, _args}) do
              elapsed = monotonic_since(start)
              Logger.error("Exception in \#{inspect(module)}.\#{name}: \#{inspect(exception_info)}", took: elapsed)
            end
          end
        end
      end

  To use this in your behaviour implementation:

      defmodule MyApp.Server.FooServer do
        use MyApp.GenServer

        @impl true
        def init(args) do
          {:ok, args}
        end

        @impl true
        def terminate(reason, _state) do
          :ok
        end

        @impl true
        def handle_continue(:initialize, state) do
          {:noreply, state}
        end
      end

  ## How It Works

  The module leverages Elixir's metaprogramming capabilities to intercept and modify function definitions at compile
  time. It does this through three main mechanisms:

  1. **Macro `__using__/1`**:

      - When you `use #{inspect(__MODULE__)}` in your module, it sets up necessary module attributes and hooks.
      - It collects all callbacks defined by the behaviours your module implements (specified via `@behaviour`
        attributes declared before `use #{inspect(__MODULE__)}`), storing them in `@vs_hook_targets`.
      - This ensures that only the specified behaviour callbacks are targeted for hooking.

  2. **Definition Capture with `@on_definition`**:

      - The `@on_definition` module attribute is set to `#{inspect(__MODULE__)}`, so every time a function is defined,
        the `__on_definition__/6` callback is invoked.
      - This function checks if the defined function matches any behaviour callbacks by name and arity.
      - Matching functions are recorded in the `@vs_hooked` module attribute for later processing.

  3. **Code Injection with `@before_compile`**:

      - before compilation, the `__before_compile__/1` macro is called.
      - It retrieves the list of functions to be hooked from `@vs_hooked`.
      - For each function, it checks if corresponding `start`, `stop`, and/or `exception` hooks are defined.
      - It generates new function definitions that wrap the original functions with these hooks.
      - Uses `defoverridable` to make the original function overridable.
      - Calls `super(args)` to invoke the original implementation.

  See the `Module` module for more information on these compile time callbacks.

  ### Function Wrapping Logic

  The wrapping logic depends on which hooks are defined but only injects the required code for the hooks defined.

  ### Hook Function Arity and Parameters

  - **`start` Hook**:

      - Must have the same arity as the original callback function.
      - Receives the same arguments that will be passed to the callback.

  - **`stop` and `exception` Hooks**:

      - Must have an arity of the original function's arity plus two (2).
      - Receive:
          - The `result` (or exception information) of the original function as the first argument.
          - The `start` hook's result as the second argument (or `nil` if no `start` hook is defined).
          - The original function's arguments as the subsequent arguments.

  ### Handling Arity Variants

  Callback targets can be defined with variadic arguments can safely be defined. The module generates overrides for only
  the callbacks defined in the behaviour and explicitly calls the same arity variant of the hook.

  """

  defmacro __using__(opts) do
    quote do
      if Module.has_attribute?(__MODULE__, :vs_hook_targets) do
        existing = Module.get_attribute(__MODULE__, :vs_hook_targets)
        Module.delete_attribute(__MODULE__, :vs_hook_targets)
        existing
      else
        Module.register_attribute(__MODULE__, :vs_hooked, accumulate: true)
        @on_definition Decorated.LifecycleHook
        @before_compile Decorated.LifecycleHook
        []
      end
      |> Decorated.LifecycleHook.build_targets(unquote(opts))
      |> then(&Module.put_attribute(__MODULE__, :vs_hook_targets, &1))
    end
  end

  def __on_definition__(env, kind, name, args, _guards, _body) do
    for arity <- arity_variants(args) do
      with true <- {name, arity} in Module.get_attribute(env.module, :vs_hook_targets),
           false <- Enum.any?(Module.get_attribute(env.module, :vs_hooked), &match?({^kind, ^name, ^arity}, &1)) do
        Module.put_attribute(env.module, :vs_hooked, {kind, name, arity})
      end
    end
  end

  defmacro __before_compile__(env) do
    hooked = Module.get_attribute(env.module, :vs_hooked) |> Enum.reverse()
    Module.delete_attribute(env.module, :vs_hooked)

    for {kind, name, arity} <- hooked do
      start_hook = if_defined_or_default_or_nil(env.module, {:"#{name}_start", arity}, {:__default_start__, 1})
      stop_hook = if_defined_or_default_or_nil(env.module, {:"#{name}_stop", arity + 2}, {:__default_stop__, 3})
      exception_hook = if_defined_or_default_or_nil(env.module, {:"#{name}_exception", arity + 2}, {:__default_exception__, 3})
      args = generate_args(arity, nil)

      unless start_hook == nil && stop_hook == nil && exception_hook == nil do
        quote do
          unquote(inject_start_hook(start_hook, env.module, name, args))
          unquote(inject_try_rescue_catch_hook(exception_hook, env.module, name, args))
          unquote(inject_stop_hook(stop_hook, env.module, name, args))
          var!(result)
        end
        |> override(kind, name, args)
      end
    end
  end

  def build_targets(existing, opts) do
    cond do
      opts[:behaviour] -> opts[:behaviour].behaviour_info(:callbacks)
      opts[:targets] -> opts[:targets]
      true -> raise CompileError, description: "must specify either :behaviour or :targets"
    end
    |> filter_if_present(Keyword.get(opts, :only, []))
    |> reject_if_present(Keyword.get(opts, :exclude, []))
    |> Kernel.++(existing)
    |> Enum.dedup()
    |> Enum.sort()
  end

  defp filter_if_present(targets, only)
  defp filter_if_present(targets, []), do: targets
  defp filter_if_present(targets, only), do: Enum.filter(targets, fn fa -> fa in only end)

  defp reject_if_present(targets, exclude)
  defp reject_if_present(targets, []), do: targets
  defp reject_if_present(targets, exclude), do: Enum.reject(targets, fn fa -> fa in exclude end)

  # We need to account for variants defined as `var \\ default` and how that affects the definition
  # of the targeted function
  defp arity_variants(args) do
    max = length(args)
    min = length(for arg <- args, !match?({:\\, _, _}, arg), do: arg)
    min..max//1
  end

  defp generate_args(0, _caller), do: []
  defp generate_args(n, caller), do: for(i <- 1..n, do: Macro.var(:"var_#{i}", caller))

  defp if_defined_or_default_or_nil(module, {hook, arity}, {default_hook, default_arity}) do
    cond do
      Module.defines?(module, {hook, arity}, :def) -> hook
      Module.defines?(module, {hook, arity}, :defp) -> hook
      Module.defines?(module, {default_hook, default_arity}, :def) -> default_hook
      Module.defines?(module, {default_hook, default_arity}, :defp) -> default_hook
      true -> nil
    end
  end

  defp inject_start_hook(start_hook, module, name, args) do
    case start_hook do
      nil ->
        quote do
          var!(start) = nil
        end

      :__default_start__ ->
        quote do
          var!(start) = __default_start__({unquote(module), unquote(name), [unquote_splicing(args)]})
        end

      _ ->
        quote do
          var!(start) = unquote(start_hook)(unquote_splicing(args))
        end
    end
  end

  defp inject_try_rescue_catch_hook(exception_hook, module, name, args) do
    case exception_hook do
      nil ->
        quote do
          var!(result) = super(unquote_splicing(args))
        end

      :__default_exception__ ->
        quote do
          var!(result) =
            try do
              super(unquote_splicing(args))
            rescue
              reason ->
                __default_exception__(
                  {:error, reason, __STACKTRACE__},
                  var!(start),
                  {unquote(Macro.escape(module)), unquote(name), [unquote_splicing(args)]}
                )

                reraise reason, __STACKTRACE__
            catch
              :exit, reason ->
                __default_exception__(
                  {:exit, reason, __STACKTRACE__},
                  var!(start),
                  {unquote(Macro.escape(module)), unquote(name), [unquote_splicing(args)]}
                )

                :erlang.raise(:exit, reason, __STACKTRACE__)

              :throw, thrown ->
                __default_exception__(
                  {:throw, thrown, __STACKTRACE__},
                  var!(start),
                  {unquote(Macro.escape(module)), unquote(name), [unquote_splicing(args)]}
                )

                :erlang.raise(:throw, thrown, __STACKTRACE__)
            end
        end

      _ ->
        quote do
          var!(result) =
            try do
              super(unquote_splicing(args))
            rescue
              reason ->
                unquote(exception_hook)({:error, reason, __STACKTRACE__}, var!(start), unquote_splicing(args))
                reraise reason, __STACKTRACE__
            catch
              :exit, reason ->
                unquote(exception_hook)({:exit, reason, __STACKTRACE__}, var!(start), unquote_splicing(args))
                :erlang.raise(:exit, reason, __STACKTRACE__)

              :throw, thrown ->
                unquote(exception_hook)({:throw, thrown, __STACKTRACE__}, var!(start), unquote_splicing(args))
                :erlang.raise(:throw, thrown, __STACKTRACE__)
            end
        end
    end
  end

  defp inject_stop_hook(stop_hook, module, name, args) do
    case stop_hook do
      nil ->
        nil

      :__default_stop__ ->
        quote do
          __default_stop__(var!(result), var!(start), {unquote(Macro.escape(module)), unquote(name), [unquote_splicing(args)]})
        end

      _ ->
        quote do
          unquote(stop_hook)(var!(result), var!(start), unquote_splicing(args))
        end
    end
  end

  defp override(body, kind, name, args) do
    quote do
      defoverridable [{unquote(name), unquote(length(args))}]
      Kernel.unquote(kind)(unquote(name)(unquote_splicing(args)), do: unquote(body))
    end
  end

  defmacro monotonic_instant do
    quote do
      System.monotonic_time()
    end
  end

  defmacro monotonic_since(instant, time_unit) when time_unit in [:second, :millisecond, :microsecond, :nanosecond] do
    unit =
      case time_unit do
        :second -> "s"
        :millisecond -> "ms"
        :microsecond -> "μs"
        :nanosecond -> "ns"
      end

    quote generated: true do
      case unquote(instant) do
        nil -> nil
        instant -> "#{(System.monotonic_time() - instant) / System.convert_time_unit(1, unquote(time_unit), :native)}#{unquote(unit)}"
      end
    end
  end
end
