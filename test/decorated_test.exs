defmodule DecoratedTest do
  use ExUnit.Case

  doctest_file("README.md", tags: [:doctest])
  doctest Decorated, tags: [:doctest]
  doctest Decorated.Dbg, tags: [:doctest]
  doctest Decorated.Hooks, tags: [:doctest]
  doctest Decorated.Logger, tags: [:doctest]
end
