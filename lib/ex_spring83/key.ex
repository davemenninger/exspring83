defmodule ExSpring83.Key do
  @moduledoc """
  Handling keys with the special Spring83 properties
  """

  @regex ~r/ed[0-9]{4}$/i
  @valid_years 2022..2099

  @doc """
  Validate if a key is a valid Spring83 key

  0xFAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983 is the test key
  """
  @spec valid_public_key?(binary() | integer()) :: boolean()
  def valid_public_key?("fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983"),
    do: true

  def valid_public_key?(0xFAD415FBAA0339C4FD372D8287E50F67905321CCFD9C43FA4C20AC40AFED1983),
    do: true

  def valid_public_key?(public_key) when is_binary(public_key) do
    valid_length?(public_key) and valid_suffix?(public_key)
  end

  def valid_public_key?(public_key) when is_integer(public_key) do
    valid_length?(public_key) and valid_suffix?(public_key)
  end

  @doc """
  Validate that the key is 32 bytes
  """
  @spec valid_length?(binary() | integer()) :: boolean()
  def valid_length?(key) when is_binary(key) do
    case Integer.parse(key, 16) do
      {i, ""} -> valid_length?(i)
      _ -> false
    end
  end

  def valid_length?(key) when is_integer(key) do
    32 == key |> :binary.encode_unsigned() |> byte_size()
  end

  @doc """
  Validate that the key ends with ed[0-9]{4}
  """
  @spec valid_suffix?(binary() | integer()) :: boolean()
  def valid_suffix?(public_key) when is_integer(public_key) do
    public_key |> Integer.to_string(16) |> valid_suffix?()
  end

  def valid_suffix?(string) when is_binary(string) do
    String.match?(string, @regex) and match_year_range?(string)
  end

  @spec match_year_range?(binary()) :: boolean()
  def match_year_range?(string) do
    last_four = String.slice(string, -4..-1)

    case Integer.parse(last_four) do
      :error -> false
      {integer, ""} -> integer in @valid_years
      _ -> false
    end
  end

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
