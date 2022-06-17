defmodule ExSpring83.Key do
  @moduledoc """
  Handling keys with the special Spring83 properties
  """

  alias __MODULE__

  @enforce_keys [:integer, :string, :binary]
  defstruct integer: nil, string: nil, binary: nil

  @type t :: %__MODULE__{integer: integer(), string: String.t(), binary: binary()}

  @regex ~r/83e(0[1-9]|1[0-2])(\d\d)$/i

  @test_key %{
    integer: 0xAB589F4DDE9FCE4180FCF42C7B05185B0A02A5D682E353FA39177995083E0583,
    string: "AB589F4DDE9FCE4180FCF42C7B05185B0A02A5D682E353FA39177995083E0583",
    binary:
      <<171, 88, 159, 77, 222, 159, 206, 65, 128, 252, 244, 44, 123, 5, 24, 91, 10, 2, 165, 214,
        130, 227, 83, 250, 57, 23, 121, 149, 8, 62, 5, 131>>
  }

  def test_key, do: struct(Key, @test_key)

  @doc """
  Validate if a key is a valid Spring83 key

  0xFAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983 is the test key
  """
  @spec valid_public_key?(Key.t()) :: boolean()
  def valid_public_key?(
        %Key{integer: 0xFAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983} =
          public_key
      ) do
    normalize(public_key.integer) == normalize(public_key.string)
  end

  def valid_public_key?(
        %Key{string: "FAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983"} =
          public_key
      ) do
    normalize(public_key.integer) == normalize(public_key.string)
  end

  def valid_public_key?(
        %Key{string: "fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983"} =
          public_key
      ) do
    normalize(public_key.integer) == normalize(public_key.string)
  end

  def valid_public_key?(%Key{} = public_key) do
    valid_length?(public_key) and valid_suffix?(public_key) and
      normalize(public_key.integer) == normalize(public_key.string)
  end

  @doc """
  Validate that the key is 32 bytes
  """
  @spec valid_length?(Key.t()) :: boolean()
  def valid_length?(%Key{binary: binary}) when is_binary(binary) do
    32 == byte_size(binary)
  end

  @doc """
  Validate that the key ends with ed[0-9]{4}
  """
  @spec valid_suffix?(Key.t()) :: boolean()
  def valid_suffix?(%Key{string: string}) when is_binary(string) do
    # and match_year_range?(string)
    String.match?(string, @regex)
  end

  # TODO: spec
  def normalize(public_key) when is_integer(public_key) do
    {:ok,
     %Key{
       integer: public_key,
       string: public_key |> Integer.to_string(16),
       binary: public_key |> :binary.encode_unsigned()
     }}
  end

  def normalize(public_key) when is_binary(public_key) do
    case Integer.parse(public_key, 16) do
      {i, ""} ->
        {:ok,
         %Key{
           integer: i,
           string: public_key |> String.upcase(),
           binary: public_key |> String.upcase() |> Base.decode16!()
         }}

      _ ->
        {:error, "can't parse string to integer"}
    end
  end

  def normalize!(public_key) do
    case normalize(public_key) do
      {:ok, %Key{} = key} -> key
      {:error, error} -> raise error
    end
  end

  # TODO validate unexpired

  @spec puts_keypair({Ed25519.key(), Ed25519.key()}) :: :ok
  def puts_keypair({secret_key, public_key}) do
    IO.puts("""
    Public key: #{puts_key(public_key)}
    Secret key: #{puts_key(secret_key)}
    """)
  end

  @spec puts_key(Ed25519.key()) :: String.t()
  def puts_key(key) do
    Base.encode16(key, case: :lower)
  end
end
