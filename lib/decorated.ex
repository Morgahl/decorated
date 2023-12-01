defmodule Decorated do
  @moduledoc """
  This module provides a single macro `use Decorated` that can be used to decorate functions with other functions. The `use Decorated` macro
  accepts a list of modules that define decorators. The decorators are imported into the module in the order they are passed. Please refer
  to the documentation for the individual decorators for more information.

  ## Example

      defmodule MyMath do
        use Decorated, :dbg
        use Decorated, :hooks
        use Decorated, :logger

        @decorate pre(fn -> IO.inspect({a, b}, label: "pre") end)
        @decorate around(
                    fn -> IO.inspect({a, b}, label: "around pre") end,
                    &IO.inspect({a, b, &1, &2}, label: "around post")
                  )
        @decorate post(&IO.inspect({a, b, &1}, label: "post"))
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}
      end

      iex> MyMath.add(1, 2)
      #> pre: {1, 2}
      #> around pre: {1, 2}
      #> around post: {1, 2, {:ok, 3}, nil}
      #> post: {1, 2, {:ok, 3}}
      {:ok, 3}
  """

  @type decorators :: :dbg | :hooks | :logger
  @type opts :: [decorators() | {decorators(), Keyword.t()}]

  @spec __using__(opts :: opts()) :: no_return()
  defmacro __using__(:dbg), do: quote(do: use(Decorated.Dbg))

  defmacro __using__(dbg: opts) when is_list(opts) do
    quote do
      use Decorated.Dbg, unquote(opts)
    end
  end

  defmacro __using__(:hooks), do: quote(do: use(Decorated.Hooks))

  defmacro __using__(hooks: opts) when is_list(opts) do
    quote do
      use Decorated.Hooks, unquote(opts)
    end
  end

  defmacro __using__(:logger), do: quote(do: use(Decorated.Logger))

  defmacro __using__(logger: opts) when is_list(opts) do
    quote do
      use Decorated.Logger, unquote(opts)
    end
  end
end
