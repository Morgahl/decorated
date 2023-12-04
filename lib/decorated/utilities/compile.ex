defmodule Decorated.Utilites.Compile do
  @moduledoc false

  @drop_context_fields [:args]

  defmacro raise_error(desc) do
    quote(do: raise(CompileError, description: unquote(desc), file: unquote(__CALLER__.file), line: unquote(__CALLER__.line)))
  end

  defmacro raise_error(desc, metadata, %Macro.Env{} = env \\ __CALLER__) do
    file = resolve_file(metadata, env)
    line = resolve_line(metadata, env)
    quote(do: raise(CompileError, description: unquote(desc), file: unquote(file), line: unquote(line)))
  end

  def cleanup_ctx(ctx) do
    ctx
    |> Map.drop(@drop_context_fields)
    |> Macro.escape()
  end

  def get_ast_function_arity!({:fn, _, [{:->, _, [[], _]}]}), do: 0
  def get_ast_function_arity!({:fn, _, [{:->, _, [[_], _]}]}), do: 1
  def get_ast_function_arity!({:fn, _, [{:->, _, [args, _]}]}), do: length(args)
  def get_ast_function_arity!({:&, _, [{:/, _, [_, arity]}]}), do: arity

  def get_ast_file_location!({_, meta, _}), do: meta[:file]

  def get_ast_line_location!({_, meta, _}), do: meta[:line]

  defp resolve_file(opts, %Macro.Env{file: file}) when is_list(opts), do: Keyword.get(opts, :file, file)
  defp resolve_file(opts, %Macro.Env{file: file}) when is_map(opts), do: Map.get(opts, :file, file)

  defp resolve_line(opts, %Macro.Env{line: line}) when is_list(opts), do: Keyword.get(opts, :line, line)
  defp resolve_line(opts, %Macro.Env{line: line}) when is_map(opts), do: Map.get(opts, :line, line)
end
