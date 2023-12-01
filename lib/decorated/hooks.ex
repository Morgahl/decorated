defmodule Decorated.Hooks do
  @moduledoc """
  A simple decorator that provides lifecycle hooks for the decorated function.

  ## Example

      defmodule MyMath do
        use Decorated.Hooks

        @decorate pre(fn -> IO.inspect({a, b}, label: "pre") end)
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}

        @decorate post(&IO.inspect({a, b, &1}, label: "post"))
        @spec sub(number(), number()) :: number()
        def sub(a, b), do: {:ok, a - b}

        @decorate around(
                    fn -> IO.inspect({a, b}, label: "around pre") end,
                    &IO.inspect({a, b, &1, &2}, label: "around post")
                  )
        @spec multiply(number(), number()) :: number()
        def multiply(a, b), do: {:ok, a * b}
      end

      iex> MyMath.add(1, 2)
      #> pre: {1, 2}
      {:ok, 3}

      iex> MyMath.sub(1, 2)
      #> post: {1, 2, {:ok, -1}}
      {:ok, -1}

      iex> MyMath.multiply(1, 2)
      #> around pre: {1, 2}
      #> around post: {1, 2, {:ok, 2}, nil}
      {:ok, 2}
  """

  use Decorator.Define,
    pre: 1,
    post: 1,
    around: 2

  @doc """
  A decorator that calls the passed function before the decorated function is called. The decorater function has access to the the named
  argument bindings of the decorated function. All returned values from the `pre_hook/0` function are ignored.
  ## Example

      defmodule MyMath do
        use Decorated.Hooks

        @decorate pre(fn -> IO.inspect({a, b}, label: "pre") end)
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}
      end

      iex> MyMath.add(1, 2)
      #> pre: {1, 2}
      {:ok, 3}

  """
  @spec pre((-> no_return())) :: no_return()
  def pre(pre_fn, body, _ctx) do
    quote do
      unquote(pre_fn).()
      unquote(body)
    end
  end

  @doc """
  A decorator that calls the passed function post the decorated function body. The decorater function has access to the the named argument
  bindings of the decorated function in addtion to being passed the result of the decorated function. All returned values from the
  `post_hook` function are ignored.

  ## Example

      defmodule MyMath do
        use Decorated.Hooks

        @decorate post(&IO.inspect({a, b, &1}, label: "post"))
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}
      end

      iex> MyMath.add(1, 2)
      #> post: {1, 2, {:ok, 3}}
      {:ok, 3}
  """
  @spec post((result :: any() -> no_return())) :: no_return()
  def post(post_fn, body, _ctx) do
    quote do
      result = unquote(body)
      unquote(post_fn).(result)
      result
    end
  end

  @doc """
  A decorator that calls the first passed function before the decorated function is called and the second passed function after the
  decorated function body. The first decorater function has access to the the named argument bindings of the decorated function. The second
  decorater function has access to the the named argument bindings of the decorated function in addition to being passed both the result
  of the `pre_hook and the result of the decorated function. All returned values from the `post_hook` function are ignored.

  ## Example

      defmodule MyMath do
        use Decorated.Hooks

        @decorate around(
                    fn -> IO.inspect({a, b}, label: "pre") end,
                    &IO.inspect({a, b, &1, &2}, label: "post"))
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}
      end

      iex> MyMath.add(1, 2)
      #> pre: {1, 2}
      #> post: {1, 2, {:ok, 3}, {1, 2}}
      {:ok, 3}
  """
  @spec around((-> pre_hook_result), (result, pre_hook_result -> no_return())) :: no_return() when result: any(), pre_hook_result: any()
  def around(pre_fn, post_fn, body, _ctx) do
    quote do
      presult = unquote(pre_fn).()
      result = unquote(body)
      unquote(post_fn).(result, presult)
      result
    end
  end
end
