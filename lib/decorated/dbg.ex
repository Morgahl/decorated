defmodule Decorated.Dbg do
  @moduledoc """
  A simple decorator that provides `dbg/1` and `dbg/2` calls around the decorated function body.

  ## Example

      defmodule MyMath do
        use Decorated.Dbg

        @decorate dbg_log()
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}
      end

      iex> MyMath.add(1, 2)
      #> add(a, b) #=> {:ok, 3}
      {:ok, 3}
  """

  use Decorator.Define,
    dbg_log: 0,
    dbg_log: 1

  @default_dbg_config [
    pretty: true,
    syntax_colors: IO.ANSI.syntax_colors()
  ]

  @doc """
  A decorator that wraps the function body in a `dbg/2` call.

  The `dbg/2` call is configured with the provided options merged with the default options.

  ## Example

      defmodule MyMath do
        use Decorated.Dbg

        @decorate dbg_log()
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}

        @decorate dbg_log([pretty: false])
        @spec sub(number(), number()) :: number()
        def sub(a, b), do: {:ok, a - b}
      end

      iex> MyMath.add(1, 2)
      #> add(a, b) #=> {:ok, 3}
      {:ok, 3}

      iex> MyMath.sub(1, 2)
      #> add(a, b) #=> {:ok, -1}
      {:ok, -1}
  """
  @spec dbg_log() :: no_return()
  @spec dbg_log([Inspect.Opts.t()]) :: no_return()
  def dbg_log(opts \\ [], body, _ctx) do
    quote do
      # credo:disable-for-lines:2 Credo.Check.Warning.Dbg
      unquote(body)
      |> dbg(unquote(Keyword.merge(@default_dbg_config, opts)))
    end
  end
end
