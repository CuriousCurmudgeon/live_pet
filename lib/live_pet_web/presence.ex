defmodule LivePetWeb.Presence do
  use Phoenix.Presence, otp_app: :live_pet, pubsub_server: LivePet.PubSub

  alias LivePetWeb.Presence
  @active_pet_topic "active_pet"

  def track_pet(pid, pet) do
    Presence.track(pid, @active_pet_topic, pet.id, %{pet: pet})
  end

  def untrack_pet(pid, pet) do
    Presence.untrack(pid, @active_pet_topic, pet.id)
  end

  def update_pet(pid, pet) do
    Presence.update(pid, @active_pet_topic, pet.id, %{pet: pet})
  end

  def list_active_pets do
    Presence.list(@active_pet_topic)
  end
end
