defmodule ExSpring83.KeyTest do
  use ExUnit.Case
  doctest ExSpring83

  alias ExSpring83.Key

  test "valid_public_key?/1" do
    assert Key.valid_public_key?(
             "fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983"
           )

    assert Key.valid_public_key?(
             0xFAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983
           )

    assert Key.valid_public_key?(
             "1c6ffef2825b294274478bad8c80a7a610d38245a9fded18cd004c4a67ed2023"
           )

    assert Key.valid_public_key?(
             0x1C6FFEF2825B294274478BAD8C80A7A610D38245A9FDED18CD004C4A67ED2023
           )

    refute Key.valid_public_key?(
             0xA43DB95EA4181BEC447B33FFE8914E3914CB74F468B2F8128FF20CB47F43EC98
           )

    refute Key.valid_public_key?(0xED2024)
    refute Key.valid_public_key?("nope")
  end
end
