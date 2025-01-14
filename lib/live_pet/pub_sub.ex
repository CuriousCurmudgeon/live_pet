defmodule LivePet.PubSub do
  @moduledoc """
  Functions to abstract away details of subscribing to topics and broadcasting messages
  """

  #####################
  # Active Pets Topic #
  #####################
  def subscribe_to_active_pets_topic() do
    active_pets_topic()
    |> subscribe()
  end

  def active_pets_topic, do: "active_pets"

  #############
  # Pet Topic #
  #############
  def subscribe_to_pet_topic(pet_id) do
    pet_id
    |> pet_topic()
    |> subscribe()
  end

  def pet_topic(pet_id) do
    "pet:#{pet_id}"
  end

  def broadcast_pet_update(pet) do
    pet.id
    |> pet_topic()
    |> broadcast("update", pet)
  end

  ##############
  # User Topic #
  ##############
  def subscribe_to_user_topic(user_id) do
    user_id
    |> user_topic()
    |> subscribe()
  end

  def user_topic(user_id) do
    "user:#{user_id}"
  end

  def broadcast_user_available_treats(user) do
    user.id
    |> user_topic()
    |> broadcast("available_treats", %{available_treats: user.available_treats})
  end

  defp subscribe(topic) do
    Phoenix.PubSub.subscribe(__MODULE__, topic)
  end

  defp broadcast(topic, event, message) do
    Phoenix.Channel.Server.broadcast(__MODULE__, topic, event, message)
  end
end
