defmodule DecoratedTest do
  use ExUnit.Case, async: true

  @tags [:doctest]

  doctest_file("README.md", tags: @tags)
  doctest Decorated, tags: @tags
  doctest Decorated.Dbg, tags: @tags
  doctest Decorated.Hooks, tags: @tags
  doctest Decorated.Logger, tags: @tags
  doctest Decorated.Logger.Opts, tags: @tags
  doctest Decorated.Utilites.Compile, tags: @tags
end
