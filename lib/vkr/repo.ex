defmodule Vkr.Repo do
  use Ecto.Repo,
    otp_app: :vkr,
    adapter: Ecto.Adapters.SQLite3
end
