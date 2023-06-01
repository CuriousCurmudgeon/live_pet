# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LivePet.Repo.insert!(%LivePet.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias LivePet.Pets.Pet
alias LivePet.Repo

Repo.delete_all(Pet)

pet_count = 10_000
chunk_size = 10_000

timestamp = DateTime.utc_now() |> DateTime.to_naive() |> NaiveDateTime.truncate(:second)

1..pet_count
|> Enum.map(fn i ->
  %{name: "pet-#{i}", age: 0, user_id: 1, inserted_at: timestamp, updated_at: timestamp}
end)
|> Enum.chunk_every(chunk_size)
|> Enum.each(fn pets -> Repo.insert_all(Pet, pets) end)
