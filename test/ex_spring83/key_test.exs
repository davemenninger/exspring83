defmodule ExSpring83.KeyTest do
  use ExUnit.Case
  doctest ExSpring83

  alias ExSpring83.Key

  test "normalize to struct" do
    assert Key.test_key() ==
             Key.normalize!(0xAB589F4DDE9FCE4180FCF42C7B05185B0A02A5D682E353FA39177995083E0583)

    assert Key.test_key() ==
             Key.normalize!(
               77_502_079_126_469_152_300_067_950_456_082_758_891_841_919_142_306_220_715_969_033_340_501_723_317_635
             )

    assert Key.test_key() ==
             Key.normalize!("ab589f4dde9fce4180fcf42c7b05185b0a02a5d682e353fa39177995083e0583")

    assert Key.test_key() ==
             Key.normalize!("AB589F4DDE9FCE4180FCF42C7B05185B0A02A5D682E353FA39177995083E0583")
  end

  test "valid_public_key?/1" do
    assert "ab589f4dde9fce4180fcf42c7b05185b0a02a5d682e353fa39177995083e0583"
           |> Key.normalize!()
           |> Key.valid_public_key?()

    assert 0xAB589F4DDE9FCE4180FCF42C7B05185B0A02A5D682E353FA39177995083E0583
           |> Key.normalize!()
           |> Key.valid_public_key?()

    assert "CA93846AE61903A862D44727C16FED4B80C0522CAB5E5B8B54763068B83E0623"
           |> Key.normalize!()
           |> Key.valid_public_key?()

    assert 0xCA93846AE61903A862D44727C16FED4B80C0522CAB5E5B8B54763068B83E0623
           |> Key.normalize!()
           |> Key.valid_public_key?()

    assert "ca93846ae61903a862d44727c16fed4b80c0522cab5e5b8b54763068b83e0623"
           |> Key.normalize!()
           |> Key.valid_public_key?()

    # c761fd8e4abc6ee4ca6d0883a95b7f0c88d33835a085b382dfbfb435283e0623

    refute 0xA43DB95EA4181BEC447B33FFE8914E3914CB74F468B2F8128FF20CB47F43EC98
           |> Key.normalize!()
           |> Key.valid_public_key?()
  end

  test "valid_length?/1" do
  end

  test "valid_suffix?/1" do
  end
end
