# LivePet

LivePet is a demo app for [my talk at THAT Conference 2023](https://that.us/activities/2P8aHDB0t3hnZBOiTVkw/) on Elixir and LiveView. The app aims to demonstrate OTP and LiveView by simulating virtual pets that users can interact with through a LiveView page.

If you want to give it a try, visit https://that-pet.fly.dev/.

## Installation

LivePet is a standard Phoenix app. To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Pet Architecture
On startup, the app starts `LivePet.PetInitSupervisor` to start up every pet and a Registry for what processes are currently viewing a pet. Pets run under a `PartitionSupervisor` that starts up `DynamicSupervisors`. `DynamicSupervisors` cannot be given a list of children on startup, so a separate task is started to start all the pet processes.

A lot of this is very naive and not optimized. The goal is to show off some of the power of Elixir, but not going overboard with optimization. For example, it shows how to create a `PartitionSupervisor`, but doesn't really take advantage of it. Starting every pet is still done in a single process. This becomes a bottleneck when simulating large numbers of pets. I started 120K pets and it took over a half hour to start all of them.

Each pet's state updates every five seconds. Currently, they just get older and hungrier. Persistence is handled by a separate `LivePet.Pets.Persister` process that persists every pet to the DB every minute. Moving the persistence out of the each pet process is a naive strategy to limit the number of DB connections. Allowing each pet to persist every X ticks can lead to DB connections being a bottleneck.

## LiveView
Navigating to the live view for a pet starts registers the live view process with the pet viewers registry. On every tick, the pet process dispatches a message to all of it's viewers so that the UI can be updated with the new state.

The live view does not currently handle viewing a dead pet because there is no process to connect to.
