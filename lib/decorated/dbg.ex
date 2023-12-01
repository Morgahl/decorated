defmodule Decorated.Dbg do
  @moduledoc """
  A simple decorator that provides `dbg/1` and `dbg/2` calls around the decorated function body.
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
  """
  @spec dbg_log() :: no_return()
  @spec dbg_log([Inspect.Opts.t()]) :: no_return()
  def dbg_log(opts \\ [], body, _ctx) do
    quote location: :keep do
      # credo:disable-for-lines:2 Credo.Check.Warning.Dbg
      unquote(body)
      |> dbg(unquote(Keyword.merge(@default_dbg_config, opts)))
    end
  end
end
