defmodule MyMath do
  @moduledoc """
  A simple module that demonstrates the Decorated.Logger decorator. It's full of arbitrary rules that we don't like and we want to log when
  they're broken.

  I am making use of macros to build the decorators for... reasons. I'm not sure if this is a good idea or not. I'm also not sure if I'm
  using the Decorated.Logger decorator correctly.
  """
  use Decorated, :dbg
  use Decorated, :hooks
  use Decorated, :logger

  import MyMath.Macros
  alias MyMath.Macros

  @decorate dbg_log()
  @decorate around(
              fn -> IO.inspect({}, label: "pre_hook/0") end,
              fn result, presult -> IO.inspect({result, presult}, label: "post_hook/2") end
            )
  @decorate around(
              fn ctx -> IO.inspect({ctx}, label: "pre_hook/1", width: :infinity) end,
              fn result, presult, ctx -> IO.inspect({result, presult, ctx}, label: "post_hook/3", width: :infinity) end
            )
  @decorate info_log(catch: :error, metadata: [foo: :bar])

  @doc """
  Perform an arbitrary set of math operations on two numbers using the `|>` operator. best use is `dbg_log/0` or `dbg_log/1` to see the
  result of each operation.
  """
  @spec debug_me!(number(), number()) :: number()
  def debug_me!(a, b) do
    add!(a, b)
    |> pow!(b)
    |> divide!(a)
  end

  @decorate_all info_log(catch: :error, metadata: [foo: :bar])

  @doc """
  Returns true if the given option is `:none`.
  """
  @spec is_none(Macros.option(any())) :: boolean()
  def is_none(:none), do: true
  def is_none(_), do: false

  @doc """
  Adds two numbers together. Arbitrarily we hate strings and we hate the same value so we return an error if either of those are passed in.
  """
  @spec add(number(), number()) :: Macros.result(number(), :same_value | :no_strings)
  def add(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def add(a, a), do: err(:same_value)
  def add(a, b), do: ok(a + b)

  @doc """
  Adds two numbers together. Arbitrarily we hate strings and we hate the same value so we raise an error if either of those are passed in.
  """
  @spec add!(number(), number()) :: number()
  def add!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def add!(a, a), do: raise_same_value()
  def add!(a, b), do: a + b

  @doc """
  Subtracts two numbers. Arbitrarily we hate strings and we hate the same value so we return an error if either of those are passed in.
  """
  @spec sub(number(), number()) :: Macros.result(number(), :same_value | :no_strings)
  def sub(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def sub(a, a), do: err(:same_value)
  def sub(a, b), do: ok(a - b)

  @doc """
  Subtracts two numbers. Arbitrarily we hate strings and we hate the same value so we raise an error if either of those are passed in.
  """
  @spec sub!(number(), number()) :: number()
  def sub!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def sub!(a, a), do: raise_same_value()
  def sub!(a, b), do: a - b

  @doc """
  Divides two numbers. Arbitrarily we hate strings and we hate dividing by zero so we return an error if either of those are passed in.
  """
  @spec divide(number(), number()) :: Macros.result(number(), :division_by_zero | :no_strings)
  def divide(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def divide(_a, 0), do: err(:division_by_zero)
  def divide(a, b), do: ok(a / b)

  @doc """
  Divides two numbers. Arbitrarily we hate strings and we hate dividing by zero so we raise an error if either of those are passed in.
  """
  @spec divide!(number(), number()) :: number()
  def divide!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def divide!(_a, 0), do: raise_division_by_zero()
  def divide!(a, b), do: a / b

  @doc """
  Multiplies two numbers. Arbitrarily we hate strings so we return an error if either of those are passed in.
  """
  @spec multiply(number(), number()) :: Macros.result(number(), :no_strings)
  def multiply(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def multiply(a, b), do: ok(a * b)

  @doc """
  Multiplies two numbers. Arbitrarily we hate strings so we raise an error if either of those are passed in.
  """
  @spec multiply!(number(), number()) :: number()
  def multiply!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def multiply!(a, b), do: a * b

  @doc """
  Raises a number to a power. Arbitrarily we hate strings so we return an error if either of those are passed in.
  """
  @spec pow(number(), number()) :: Macros.result(number(), :no_strings)
  def pow(a, b) when is_binary(a) or is_binary(b), do: err(:no_strings)
  def pow(a, b), do: ok(a ** b)

  @doc """
  Raises a number to a power. Arbitrarily we hate strings so we raise an error if either of those are passed in.
  """
  @spec pow!(number(), number()) :: number()
  def pow!(a, b) when is_binary(a) or is_binary(b), do: raise_no_strings()
  def pow!(a, b), do: a ** b
end
