defmodule Mix.Tasks.NextDemo do
  @moduledoc """
  Takes care of all bookkeeping to advance to the next step in the demo.
  This includes reverting any uncommitted changes, advancing to next
  demo tag, and applying any migrations.
  """
  use Mix.Task

  @shortdoc "Advance to the next demo"
  def run(_) do
    current_tag = get_current_tag()
    IO.puts("Current tag: #{current_tag}")

    IO.write("Reverting local changes... ")
    revert_changes()
    IO.puts("✅")

    next_tag = get_next_tag(current_tag)
    IO.write("Advancing to tag #{next_tag}... ")
    checkout_tag(next_tag)
    IO.puts("✅")

    IO.puts("Applying migrations")
    apply_migrations()
    IO.puts("Migrations complete ✅")

    IO.puts(IO.ANSI.format([:blue, :bright, "Ready for next demo ✅"]))
  end

  defp get_current_tag() do
    System.cmd("git", ["describe", "--tags"])
    |> elem(0)
    |> String.trim()
  end

  defp revert_changes() do
    System.cmd("git", ["checkout"])
  end

  defp get_next_tag(current_tag) do
    [demo_number_string | demo_tail] = String.split(current_tag, "-")
    {demo_number, _} = Integer.parse(demo_number_string)

    next_demo_number_string =
      (demo_number + 1)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    [next_demo_number_string | demo_tail]
    |> Enum.join("-")
  end

  defp checkout_tag(tag) do
    System.cmd("git", ["checkout", tag])
  end

  defp apply_migrations do
    System.cmd("mix", ["ecto.migrate"])
  end
end
