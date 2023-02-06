defmodule Cloak.Padding do
  def pad(str, size \\ 16) do
    if byte_size(str) < size do
      str
      |> Kernel.<>("\x80")
      |> String.pad_trailing(size - 1, "\x00")
    else
      str
    end
  end

  def unpad(str) do
    String.replace(str, ~r/\x80[\x00]+$/, "")
  end
end
