defmodule MyMath do
  @moduledoc """
  A simple module that demonstrates the Decorated.Logger decorator.
  """

  @type ok(t) :: {:ok, t}
  @type err(e) :: {:error, e}
  @type result(t, e) :: {:ok, t} | {:error, e}
  @type option(t) :: {:ok, t} | :none

  @spec ok(any()) :: {:ok, any()}
  defmacrop ok(ok), do: quote(do: {:ok, unquote(ok)})

  @spec err(any()) :: {:error, any()}
  defmacrop err(error), do: quote(do: {:error, unquote(error)})

  @spec raise_same_value() :: no_return()
  defmacrop raise_same_value, do: quote(do: raise("do not pass the same value to #{inspect(__MODULE__)} functions"))

  @spec raise_no_strings() :: no_return()
  defmacrop raise_no_strings, do: quote(do: raise("do not pass strings to #{inspect(__MODULE__)} functions"))

  @spec raise_division_by_zero() :: no_return()
  defmacrop raise_division_by_zero, do: quote(do: raise("do not divide by zero in #{inspect(__MODULE__)} functions"))

  use Decorated, :dbg
  use Decorated, :hooks
  use Decorated, :logger

  @decorate dbg_log()
  @decorate info_log(catch: :error)
  @decorate around(
              fn -> IO.inspect({a, b}, label: "pre") end,
              &IO.inspect({a, b, &1, &2}, label: "post")
            )
  @spec debug_me!(number(), number()) :: number()
  def debug_me!(a, b) do
    add!(a, b)
    |> pow!(b)
    |> divide!(a)
  end

  @decorate_all info_log(catch: :error)

  @doc """
  Adds two numbers together.
  """
  @spec is_none(option(any())) :: boolean()
  def is_none(:none), do: :none
  def is_none(_), do: false

  @spec add(number(), number()) :: result(number(), :same_value | :no_strings)
  def add(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def add(a, a), do: err(:same_value)
  def add(a, b), do: ok(a + b)

  @spec add!(number(), number()) :: number()
  def add!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def add!(a, a), do: raise_same_value()
  def add!(a, b), do: a + b

  @spec sub(number(), number()) :: result(number(), :same_value | :no_strings)
  def sub(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def sub(a, a), do: err(:same_value)
  def sub(a, b), do: ok(a - b)

  @spec sub!(number(), number()) :: number()
  def sub!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def sub!(a, a), do: raise_same_value()
  def sub!(a, b), do: a - b

  @spec divide(number(), number()) :: result(number(), :division_by_zero | :no_strings)
  def divide(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def divide(_a, 0), do: err(:division_by_zero)
  def divide(a, b), do: ok(a / b)

  @spec divide!(number(), number()) :: number()
  def divide!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def divide!(_a, 0), do: raise_division_by_zero()
  def divide!(a, b), do: a / b

  @spec multiply(number(), number()) :: result(number(), :no_strings)
  def multiply(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def multiply(a, b), do: ok(a * b)

  @spec multiply!(number(), number()) :: number()
  def multiply!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def multiply!(a, b), do: a * b

  @spec pow(number(), number()) :: result(number(), :no_strings)
  def pow(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def pow(a, b), do: ok(a ** b)

  @spec pow!(number(), number()) :: number()
  def pow!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def pow!(a, b), do: a ** b
end
