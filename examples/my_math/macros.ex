defmodule MyMath.Macros do
  @moduledoc false

  @type ok(t) :: {:ok, t}
  @type err(e) :: {:error, e}
  @type result(t, e) :: {:ok, t} | {:error, e}
  @type option(t) :: {:ok, t} | :none

  @spec ok(any()) :: {:ok, any()}
  defmacro ok(ok), do: quote(do: {:ok, unquote(ok)})

  @spec err(any()) :: {:error, any()}
  defmacro err(error), do: quote(do: {:error, unquote(error)})

  @spec raise_same_value() :: no_return()
  defmacro raise_same_value, do: quote(do: raise("do not pass the same value to #{inspect(__MODULE__)} functions"))

  @spec raise_no_strings() :: no_return()
  defmacro raise_no_strings, do: quote(do: raise("do not pass strings to #{inspect(__MODULE__)} functions"))

  @spec raise_division_by_zero() :: no_return()
  defmacro raise_division_by_zero, do: quote(do: raise("do not divide by zero in #{inspect(__MODULE__)} functions"))
end
