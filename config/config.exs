# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

if config_env() == :test do
  import_config "test.exs"
end
