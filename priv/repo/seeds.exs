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

alias LivePet.Accounts
alias LivePet.Pets.Pet
alias LivePet.Repo

Repo.delete_all(Pet)

pet_count = 10_000
chunk_size = 10_000

# Copied from LivePet.AccountsFixtures. Test module stuff
# isn't available here, but it would be nice if it was.
{:ok, user} =
  %{
    email: "user#{System.unique_integer()}@example.com",
    password: "hello world!"
  }
  |> Accounts.register_user()

timestamp = DateTime.utc_now() |> DateTime.to_naive() |> NaiveDateTime.truncate(:second)

1..pet_count
|> Enum.map(fn i ->
  %{name: "pet-#{i}", age: 0, user_id: user.id, inserted_at: timestamp, updated_at: timestamp}
end)
|> Enum.chunk_every(chunk_size)
|> Enum.each(fn pets -> Repo.insert_all(Pet, pets) end)
