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

  import Decorated.Utilites.Compile

  alias Decorator.Decorate.Context

  use Decorator.Define,
    pre: 1,
    post: 1,
    around: 2

  @doc """
  ## Example

      defmodule MyMath do
        use Decorated.Hooks

        @decorate pre(fn -> IO.inspect({a, b}, label: "pre()") end)
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}

        @decorate pre(fn ctx -> IO.inspect({a, b, ctx}, label: "pre(ctx)") end)
        @spec add!(number(), number()) :: number()'
        def add!(a, b), do: a + b
      end

      iex> MyMath.add(1, 2)
      #> pre: {1, 2}
      {:ok, 3}

      iex> MyMath.add!(1, 2)
      #> pre: {1, 2, %Context{args: [1, 2], file: "lib/my_math.ex", line: 23}}
      3
  """
  @spec pre((-> no_return()) | (Context.t() -> no_return())) :: no_return()
  def pre(pre_hook, body, ctx) do
    case get_ast_function_arity!(pre_hook) do
      0 -> pre_0(pre_hook, body)
      1 -> pre_1(pre_hook, body, ctx)
      _ -> raise_error("The pre_hook function must be arity of 0 or 1", file: ctx.file, line: get_ast_line_location!(pre_hook))
    end
  end

  @doc """
  ## Example

      defmodule MyMath do
        use Decorated.Hooks

        @decorate post(&IO.inspect({a, b, &1}, label: "post(result)"))
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}

        @decorate post(fn result, presult -> IO.inspect({a, b, result, presult}, label: "post(result, ctx)"))
        @spec add!(number(), number()) :: number()
        def add!(a, b), do: a + b
      end

      iex> MyMath.add(1, 2)
      #> post: {1, 2, {:ok, 3}}
      {:ok, 3}

      iex> MyMath.add!(1, 2)
      #> post: {1, 2, 3, {1, 2}}
      3
  """
  @spec post((result :: any() -> no_return()) | (result :: any(), Context.t() -> no_return())) :: no_return()
  def post(post_hook, body, %Context{} = ctx) do
    case get_ast_function_arity!(post_hook) do
      1 -> post_1(post_hook, body)
      2 -> post_2(post_hook, body, ctx)
      _ -> raise_error("The post_hook function must be arity of 1 or 2", file: ctx.file, line: get_ast_line_location!(post_hook))
    end
  end

  @doc """
  ## Example

      defmodule MyMath do
        use Decorated.Hooks

        @decorate around(
                    fn -> IO.inspect({a, b}, label: "pre()") end,
                    &IO.inspect({a, b, &1, &2}, label: "post(result, presult)"))
        @spec add(number(), number()) :: number()
        def add(a, b), do: {:ok, a + b}

        @decorate around(
                    fn ctx -> IO.inspect({a, b, ctx}, label: "pre(ctx)") end,
                    fn result, presult, ctx -> IO.inspect({a, b, result, presult, ctx}, label: "post(ctx, result, presult)") end
        @spec add(number(), number()) :: number()
        def add!(a, b), do: a + b
      end

      iex> MyMath.add(1, 2)
      #> pre: {1, 2}
      #> post: {1, 2, {:ok, 3}, {1, 2}}
      {:ok, 3}

      iex> MyMath.add!(1, 2)
      #> pre: {1, 2, %Context{args: [1, 2], file: "b/my_math.ex", line: 23}}
      #> post: {1, 2, 3, {1, 2, %Context{args: [1, 2], file: "lib/my_math.ex", line: 23}}}
      3
  """
  @spec around((-> presult) | (ctx -> presult), (result, presult -> no_return()) | (result, presult, ctx -> no_return())) :: no_return()
        when result: any(), presult: any(), ctx: Context.t()
  def around(pre_hook, post_hook, body, %Context{} = ctx) do
    case {get_ast_function_arity!(pre_hook), get_ast_function_arity!(post_hook)} do
      {0, 2} -> around_0_2(pre_hook, post_hook, body)
      {0, 3} -> around_0_3(pre_hook, post_hook, body, ctx)
      {0, _} -> raise_error("The post_hook function must be arity of 1 or 2", file: ctx.file, line: get_ast_line_location!(post_hook))
      {1, 2} -> around_1_2(pre_hook, post_hook, body, ctx)
      {1, 3} -> around_1_3(pre_hook, post_hook, body, ctx)
      {1, _} -> raise_error("The post_hook function must be arity of 2 or 3", file: ctx.file, line: get_ast_line_location!(post_hook))
      _ -> raise_error("The pre_hook function must be arity of 0 or 1", file: ctx.file, line: get_ast_line_location!(pre_hook))
    end
  end

  defp pre_0(pre_hook, body) do
    quote do
      unquote(pre_hook).()
      unquote(body)
    end
  end

  defp pre_1(pre_hook, body, ctx) do
    quote do
      ctx = unquote(cleanup_ctx(ctx))
      unquote(pre_hook).(ctx)
      unquote(body)
    end
  end

  defp post_1(post_hook, body) do
    quote do
      result = unquote(body)
      unquote(post_hook).(result)
      result
    end
  end

  defp post_2(post_hook, body, ctx) do
    quote do
      ctx = unquote(cleanup_ctx(ctx))
      result = unquote(body)
      unquote(post_hook).(result, ctx)
      result
    end
  end

  defp around_0_2(pre_hook, post_hook, body) do
    quote do
      presult = unquote(pre_hook).()
      result = unquote(body)
      unquote(post_hook).(result, presult)
      result
    end
  end

  defp around_0_3(pre_hook, post_hook, body, ctx) do
    quote do
      ctx = unquote(cleanup_ctx(ctx))
      presult = unquote(pre_hook).()
      result = unquote(body)
      unquote(post_hook).(result, presult, ctx)
      result
    end
  end

  defp around_1_2(pre_hook, post_hook, body, ctx) do
    quote do
      ctx = unquote(cleanup_ctx(ctx))
      presult = unquote(pre_hook).(ctx)
      result = unquote(body)
      unquote(post_hook).(result, presult)
      result
    end
  end

  defp around_1_3(pre_hook, post_hook, body, ctx) do
    quote do
      ctx = unquote(cleanup_ctx(ctx))
      presult = unquote(pre_hook).(ctx)
      result = unquote(body)
      unquote(post_hook).(result, presult, ctx)
      result
    end
  end
end
