# How to Generate Encryption Keys

The easiest way to generate a key is via IEx.

    $ iex
    iex> 32 |> :crypto.strong_rand_bytes() |> Base.encode64()
    "HXCdm5z61eNgUpnXObJRv94k3JnKSrnfwppyb60nz6w="

This will generate a strong 256-bit key encoded with Base64.