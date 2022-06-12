defmodule RustMqApiTest do
  use ExUnit.Case
  doctest RustMqApi

  test "greets the world" do
    assert RustMqApi.hello() == :world
  end
end
