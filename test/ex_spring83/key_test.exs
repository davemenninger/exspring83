defmodule ExSpring83.KeyTest do
  use ExUnit.Case
  doctest ExSpring83

  alias ExSpring83.Key

  @test_key %Key{
    integer: 0xFAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983,
    string: "FAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983",
    binary:
      <<250, 212, 21, 251, 170, 3, 57, 196, 253, 55, 45, 130, 135, 229, 15, 103, 144, 83, 33, 204,
        253, 156, 67, 250, 76, 32, 172, 64, 175, 237, 25, 131>>
  }

  test "normalize to struct" do
    assert @test_key ==
             Key.normalize(0xFAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983)

    assert @test_key ==
             Key.normalize(
               113_452_935_445_073_927_171_914_826_180_527_736_397_782_166_196_513_441_183_943_331_961_718_952_499_587
             )

    assert @test_key ==
             Key.normalize("fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983")

    assert @test_key ==
             Key.normalize("FAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983")
  end

  test "valid_public_key?/1" do
    assert "fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983"
           |> Key.normalize()
           |> Key.valid_public_key?()

    assert 0xFAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983
           |> Key.normalize()
           |> Key.valid_public_key?()

    assert "1c6ffef2825b294274478bad8c80a7a610d38245a9fded18cd004c4a67ed2023"
           |> Key.normalize()
           |> Key.valid_public_key?()

    assert 0x1C6FFEF2825B294274478BAD8C80A7A610D38245A9FDED18CD004C4A67ED2023
           |> Key.normalize()
           |> Key.valid_public_key?()

    refute 0xA43DB95EA4181BEC447B33FFE8914E3914CB74F468B2F8128FF20CB47F43EC98
           |> Key.normalize()
           |> Key.valid_public_key?()
  end

  test "valid_length?/1" do
  end

  test "valid_suffix?/1" do
  end

  test "match_year_range?/1" do
  end
end
