defmodule LivePetWeb.Presence do
  use Phoenix.Presence, otp_app: :live_pet, pubsub_server: LivePet.PubSub

  alias LivePetWeb.Presence
  @active_pets_topic "active_pets"
  @active_pets_key "active_pets"

  def track_pet(pid, pet) do
    Presence.track(pid, @active_pets_topic, @active_pets_key, %{pet: pet})
  end

  def untrack_pet(pid, pet) do
    Presence.untrack(pid, @active_pets_topic, @active_pets_key)
  end

  def update_pet(pid, pet) do
    Presence.update(pid, @active_pets_topic, @active_pets_key, %{pet: pet})
  end

  def list_active_pets do
    Presence.list(@active_pets_topic)
    |> Map.get(@active_pets_key, %{})
    |> Map.get(:metas, [])
    |> Enum.map(fn %{pet: pet} -> pet end)
    |> Enum.uniq_by(fn p -> p.id end)
  end
end
