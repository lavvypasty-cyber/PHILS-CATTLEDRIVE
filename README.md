# 🐄 Phil's Cattle Drive

A fully featured **RedM RSG-Core** cattle driving job where players herd cattle across the frontier, earning money based on the distance travelled while keeping the herd together.

---

## Features

* 🤠 Ranch Hand NPCs at multiple towns.
* 🐄 Spawn and herd up to **6 cattle**.
* 🗺️ GPS route guidance to delivery locations.
* 💰 Distance-based reward system.
* 📍 Permanent start and delivery blips.
* 😱 Cattle panic if left too far behind.
* 🚚 Multiple start and destination combinations.
* 🔄 Automatic cleanup on completion or resource stop.
* 🎮 Simple NUI destination selection menu.

---

## Requirements

* `rsg-core`
* RedM
* OneSync enabled

---

## Installation

1. Place the resource in your `resources` folder.

2. Ensure it starts after `rsg-core`.

```cfg
ensure rsg-core
ensure phils-cattledrive
```

3. Restart your server.

---

## How It Works

1. Visit a **Ranch Hand** NPC.
2. Press **J** to talk to them.
3. Choose a delivery destination.
4. A herd of cattle spawns.
5. Drive the herd safely to the destination.
6. Earn money based on the journey distance.

If cattle stray too far away they'll panic and flee, so keep the herd together.

---

## Start Locations

| Location         | NPC        |
| ---------------- | ---------- |
| Valentine Corral | Ranch Hand |
| Emerald Ranch    | Ranch Hand |
| Strawberry       | Ranch Hand |
| Saint Denis      | Ranch Hand |

## Delivery Locations

| Destination        |
| ------------------ |
| MacFarlane's Ranch |
| Rhodes Depot       |
| Van Horn Docks     |
| Armadillo          |
| Tumbleweed         |

---

# Configuration

All settings are located in `config.lua`.

## General Settings

| Option               | Default   | Description                        |
| -------------------- | --------- | ---------------------------------- |
| `Config.Debug`       | `false`   | Enable debug mode                  |
| `Config.InteractKey` | `J`       | Interaction key                    |
| `Config.RequiredJob` | `nil`     | Restrict the job to a specific job |
| `Config.HerdSize`    | `6`       | Number of cattle spawned           |
| `Config.CowModel`    | `A_C_Cow` | Cattle model                       |

## Reward Settings

| Option         | Default |
| -------------- | ------- |
| Base Reward    | `$50`   |
| Per Meter      | `$0.05` |
| Reward Account | `cash`  |

### Reward Formula

```text
Reward = BaseReward + (Distance × RewardPerMeter)
```

Example:

* Distance: **2,000 meters**
* Base: **$50**
* Distance Bonus: **$100**
* Total: **$150**

---

## Gameplay Settings

| Option         | Value        |
| -------------- | ------------ |
| Panic Distance | `40.0`       |
| Despawn Timer  | `60 minutes` |
| Walk Speed     | `1.0`        |
| Target Speed   | `1.8`        |

---

## NPC Configuration

Each location includes:

* NPC model
* Position
* Heading
* Idle scenario

Example:

```lua
npc = {
    model = 'loansharking_horsechase1_males_01',
    coords = vector3(-288.6, 643.3, 113.08),
    heading = 220.0,
    scenario = 'WORLD_HUMAN_SMOKE',
}
```

You can easily replace the NPC model with any valid RedM pedestrian.

---

## Blips

Every start and delivery location automatically creates a map blip.

---

## Controls

| Key   | Action             |
| ----- | ------------------ |
| `J`   | Talk to Ranch Hand |
| Mouse | Select destination |

---

## How Cattle Behave

* Follow the player automatically.
* Recalculate formation every few seconds.
* Panic if the player gets too far away.
* Resume following once the player returns.
* Freeze when delivered.
* Automatically clean up after completion.

---

## Customisation

You can easily add more:

* Ranches
* Delivery locations
* NPCs
* Blips
* Rewards
* Herd sizes

Simply add additional entries to:

```lua
Config.StartLocations
```

or

```lua
Config.DeliveryPoints
```

using the same format.

---

## Known Behaviour

* GPS updates automatically.
* Cattle are networked for multiplayer.
* Dead cattle count as lost.
* The drive ends once all cattle are delivered or lost.

---

## Credits

**Phil's Cattle Drive**

Built for the **RSG-Core** RedM framework to bring authentic frontier cattle driving to your server.
