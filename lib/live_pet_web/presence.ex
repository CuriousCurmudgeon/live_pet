defmodule LivePetWeb.Presence do
  use Phoenix.Presence, otp_app: :live_pet, pubsub_server: LivePet.PubSub
end
