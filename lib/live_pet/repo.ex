defmodule LivePet.Repo do
  use Ecto.Repo,
    otp_app: :live_pet,
    adapter: Ecto.Adapters.Postgres
end
