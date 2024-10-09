defmodule ElixirChatTest do
  use ExUnit.Case
  doctest ElixirChat

  test "greets the world" do
    assert ElixirChat.hello() == :world
  end
end
