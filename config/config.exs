# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :cloak, json_library: Poison

import_config "#{Mix.env()}.exs"
