defmodule LivePet.Repo.Migrations.RequireUserOnPet do
  use Ecto.Migration

  def change do
    # Remove any pets that don't have an owner. This is fine since we don't have
    # any real data yet. The down migration is a no-op.
    execute("delete from pets where user_id is null", "SELECT 1")

    alter table("pets") do
      modify(:user_id, references(:users, on_delete: :delete_all),
        null: false,
        from: references(:users, on_delete: :delete_all)
      )
    end
  end
end
