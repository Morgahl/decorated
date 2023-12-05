# Decorated

A collection of Decorators.

Documentation can be found at: https://morgahl.github.io/decorated (it currently follows `main`)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `decorated` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # No `:ref`` is currently specified as `main` is the only branch and no version has been cut yet
    {:decorated, github: "morgahl/decorated"}
  ]
end
```

## Examples

Currently the only example of this library is `MyMath` located in `examples/`.

### MyMath

This example is just a really terrible wrapper around math operations with arbitrary failure conditions for the `Decorated.Logger` to trigger from.

```sh
$ MIX_ENV=examples mix run examples/my_math.exs
```
OR
```ex
$ MIX_ENV=examples iex -S mix

iex> MyMath.debug_me! 42, 3.33
```
