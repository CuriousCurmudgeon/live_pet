defmodule LivePetWeb.Presence do
  use Phoenix.Presence, otp_app: :live_pet, pubsub_server: LivePet.PubSub

  alias LivePetWeb.Presence
  @viewed_pet_topic "viewed_pet"

  def track_pet(pid, pet) do
    Presence.track(pid, @viewed_pet_topic, pet.id, %{})
  end
end
