# Sekidan Technical Test — Top-Down 2D (Godot 4)

A top-down 2D combat demo built in Godot 4 as part of the Sekidan Games technical assessment.

The project implements FSM-based player control, two enemy types with distinct behavior systems (FSM and Behavior Tree via LimboAI), three reusable combat components, and a set of game feel effects that make combat more satisfying.

---

## How to run

1. Download and install **Godot 4.6.3** (the project was built on this version; 4.6.2 should also work — the difference is a minor patch and is documented here).
2. Clone or download the repository.
3. Open Godot, click **Import**, and select the `project.godot` file.
4. The **LimboAI v1.7.1** addon is already included in `addons/limboai/` — no separate installation needed.
5. Press **F5** to run. The main scene is `world.tscn`.

---

## Controls

| Key | Action |
|-----|--------|
| W / A / S / D | Move |
| J | Attack (directional — 4 directions, alternates between 2 animations) |

---

## What was implemented

### Player

`CharacterBody2D` controlled via a **Finite State Machine** with 5 states: `Idle`, `Walk`, `Attack`, `Hurt`, `Dead`.

**Directional attack system.** The animation and hitbox position are determined by the last recorded movement direction. Each direction supports two animation variants that alternate on each attack (`attack_1`/`attack_2`, `attack_up1`/`attack_up2`, `attack_down1`/`attack_down2`), providing visual variety without duplicating logic.

**Game feel effects:**

- **Hit-stop:** on a successful hit, `Engine.time_scale` freezes to `0.0` for 80ms. The unfreeze timer uses `process_always = true` to ignore the time scale and resume correctly.
- **Screen shake:** camera shake via Tween with 8 progressively decaying steps, triggered both when landing a hit and when taking damage.
- **Attack trail:** `GPUParticles2D` node child of `HitboxComponent`, activated exactly at the impact frame alongside the hitbox.
- **Knockback:** velocity impulse calculated from the hit direction, applied in `_on_damage_received`. Decays smoothly in the `Hurt` state via `move_toward`.
- **Hurt flash:** red color modulation on the sprite when entering the `Hurt` state, reversed with a Tween.
- **Audio:** distinct sound effects for landing a hit and for taking damage.

**Death:** on entering the `Dead` state, physics processing is disabled, `HurtboxComponent` is disabled, and `CollisionShape2D` is disabled via `set_deferred` to avoid errors inside the physics callback. The player becomes fully inert.

---

### Enemy — FSM (`actors/enemy/`)

`CharacterBody2D` with a **Finite State Machine** of 5 states: `Patrol`, `Chase`, `Attack`, `Hurt`, `Dead`.

- **Signal-based detection:** the detection range uses an `Area2D` with `body_entered` / `body_exited`. There is no per-frame distance polling: `player_detected` is updated only when the player enters or exits the area.
- **Directional hitbox:** hitbox position mirrors `sprite.flip_h` (`HITBOX_OFFSET_X = 35px`).
- **Frame-accurate hit window:** the hitbox activates at frame 3 of 6 in the attack animation, by connecting `frame_changed` directly to the activation logic.
- **Attack cooldown:** 1.5s managed via a counter in `_physics_process`, without a separate Timer node.
- Knockback, hurt flash, audio on every combat event, and full collision cleanup on death.

---

### Enemy — Behavior Tree (`actors/enemy_limbo/`)

`CharacterBody2D` powered by **LimboAI v1.7.1** (GDExtension).

**Behavior Tree structure** — `BTSelector` root, re-evaluated from the top every frame:

```
BTSelector
├── BTSequence  →  BTConditionLowHealth           + BTActionFlee
├── BTSequence  →  BTConditionPlayerInAttackRange  + BTActionAttack
├── BTSequence  →  BTConditionPlayerDetected       + BTActionChase
└── BTActionPatrol  (fallback)
```

| Behavior | Activation condition | Detail |
|---|---|---|
| **Flee** (highest priority) | Health < 30% | Moves away at 120px/s until 200px of distance is maintained |
| **Attack** | Player within 60px | Frame-accurate hit window, 1.5s cooldown |
| **Chase** | Player detected (< 235px) | 80px/s toward the player |
| **Patrol** (fallback) | Always | Oscillates 120px left/right from spawn position |

**7 custom GDScript tasks** (`actors/enemy_limbo/tasks/`):
- Conditions: `BTConditionLowHealth`, `BTConditionPlayerDetected`, `BTConditionPlayerInAttackRange`
- Actions: `BTActionFlee`, `BTActionAttack`, `BTActionChase`, `BTActionPatrol`

> **Implementation note — reactive priority:** `BTActionPatrol` returns `SUCCESS` instead of `RUNNING`. A standard `BTSelector` stalls on a `RUNNING` child and does not re-evaluate higher-priority branches until that child finishes. By returning `SUCCESS`, the Selector completes the tick and re-evaluates from the root on the next frame — allowing Flee to immediately interrupt Patrol when health drops, without needing a `DynamicSelector` or any interrupt signal.

---

### Reusable components (`actors/player/`)

All three components are fully decoupled — they make no assumptions about their parent node type and can be attached to any actor without modification.

**`HealthComponent`** (`extends Node`)
Manages `current_health` and `max_health`. Emits `health_changed(new_health: float)` on every damage event and `health_depleted` when health reaches zero.

**`HitboxComponent`** (`extends Area2D`)
Exposes `damage: float` and `set_active(bool)`. Emits `hit_landed` when a hit connects (used to trigger screen shake and audio on the attacker's side). Important: `set_active()` sets `monitoring` directly and wraps `monitorable` with `set_deferred()` — see Architecture notes.

**`HurtboxComponent`** (`extends Area2D`)
Listens for overlaps with `HitboxComponent`, filters self-hits (`hitbox.owner == owner`), calculates the hit direction, notifies the hitbox via `notify_hit()`, and emits `damage_received(amount: float, direction: Vector2)`.

---

### Map

Built with separate **TileMapLayers** per function: `suelo`, `cesped_suelo`, `suelo_up`, `cesped_suelo_up`, `bridge`, `decoracion`. Physics collisions (walls, water, obstacles) live in a dedicated `Colisiones_map` layer, decoupled from rendering.

---

## Collision layer layout

| Layer | Bit | Used by |
|-------|-----|---------|
| 1 | 1 | Player body + map tiles |
| 2 | 2 | Player `HitboxComponent` |
| 3 | 4 | Player `HurtboxComponent` |
| 4 | 8 | Enemy body (FSM + LimboAI) |
| 5 | 16 | Enemy `HitboxComponent` |
| 6 | 32 | Enemy `HurtboxComponent` |
| 7 | 64 | Enemy `DetectionRange` (mask → layer 1) |

Player and enemy bodies do not collide with each other — this allows physical overlap while keeping hitbox/hurtbox detection fully functional.

---

## Project structure

```
actors/
├── player/          # Player scene, FSM states, shared components
│   ├── player.gd / player.tscn
│   ├── states.gd              # PlayerState base class
│   ├── idle.gd / walk.gd / attack.gd / hurt.gd / dead.gd
│   ├── health_component.gd
│   ├── hitbox_component.gd
│   ├── hurtbox_component.gd
│   └── attack_trail.gd
├── enemy/           # FSM-based enemy
│   ├── enemy.gd / enemy.tscn
│   ├── enemy_state.gd         # EnemyState base class
│   └── patrol.gd / chase.gd / attack.gd / hurt.gd / dead.gd
└── enemy_limbo/     # Behavior Tree enemy (LimboAI)
    ├── enemy_limbo.gd / enemy_limbo.tscn
    └── tasks/
        ├── bt_condition_low_health.gd
        ├── bt_condition_player_detected.gd
        ├── bt_condition_player_in_attack_range.gd
        ├── bt_action_flee.gd
        ├── bt_action_attack.gd
        ├── bt_action_chase.gd
        └── bt_action_patrol.gd
assets/              # Sprites and audio
addons/limboai/      # LimboAI v1.7.1 GDExtension (included in the repo)
world.tscn           # Main scene
```

---

## Architecture notes

### Why `set_active()` instead of setting `monitoring` directly

In Godot 4, modifying `monitorable` on an `Area2D` inside an area signal callback (`area_entered`, `body_entered`) raises the error `"Function blocked during in/out signal"`. The fix is to treat the two properties differently: `monitoring` can be set directly (safe outside physics), but `monitorable` must always be deferred with `set_deferred()`. `HitboxComponent.set_active(bool)` encapsulates exactly that, and is the only way to enable or disable a hitbox anywhere in the project.

### Why FSM for the player and basic enemy, but BT for the LimboAI enemy

The player and basic enemy have a small, linear state flow: transitions are direct and predictable. An FSM is simpler, more readable, and easier to debug for that case.

The LimboAI enemy needs a fourth behavior — flee — that must be able to interrupt any of the other three at runtime based on a threshold condition (health < 30%). Implementing that in an FSM would require adding `is_low_health()` checks at the start of every state, or an "emergency state" layer that complicates the logic. A Behavior Tree handles priority-based interruption natively: the highest-priority branch is always evaluated first.

### Why `BTActionPatrol` returns `SUCCESS` and not `RUNNING`

A standard `BTSelector` stops tick evaluation when it finds a `RUNNING` child, and does not re-evaluate higher-priority branches until that child finishes or fails. If `BTActionPatrol` returned `RUNNING`, the enemy would patrol indefinitely and would never react to the player appearing (the Flee, Attack, and Chase conditions would never be evaluated). By returning `SUCCESS`, the Selector completes the tick every frame and re-evaluates from the root, giving true reactive priority without a `DynamicSelector` or any interrupt mechanism.

### Why the components live in `actors/player/`

All three components are shared across actors. They were developed alongside the player and kept there to avoid an extra `components/` folder at this project scale. In a larger codebase they would live in their own top-level directory.

### LimboAI installation

The Asset Library build for Godot 4.6 only included macOS binaries. The addon was installed manually from the [GitHub releases page](https://github.com/limbonaut/limboai/releases) using the `gdextension` build for Godot 4.6. It is committed to the repo, so no additional setup is needed when opening the project.

---

## Development process

This project was my first real experience with Godot. Going in, I had a programming background but had not worked with the engine before.

Development started from the fundamentals: understanding the node tree, how signals connect, and why GDScript has constraints that other languages do not (such as the `monitorable` behavior inside callbacks). Every technical decision in this project was researched, implemented, and in many cases broken and rebuilt from scratch until the underlying reason was clear.

Midway through, I did a full project reset — technical debt had accumulated to the point where starting over was faster than patching. That was a deliberate call and it accelerated the second half of the work considerably.

The FSM enemy was the first component to work correctly. The player with all game feel effects came next. The LimboAI enemy was the last piece, implemented once there was enough clarity on how the components fit together and how to structure the behavior tree.

LimboAI had some extra setup friction: the Asset Library version had no Windows binaries for Godot 4.6.3, so the addon had to be installed manually from GitHub. That meant reading the addon documentation and understanding the `_enter` / `_tick` / `_exit` task lifecycle before writing the first condition.

What took the most time was not writing code — it was understanding when Godot expects an operation to be deferred to the end of the frame, when a signal can or cannot modify the node tree, and how to design components that made no assumptions about their context. Those constraints ended up shaping much of the final architecture.

---

## Things I would add with more time

### Combat

**Dodge roll (H key):** the spec called for a ground roll with an invincibility window. It was cut because the Tiny Swords spritesheet does not include a roll animation cycle. A technically valid approximation would have been a dash — a velocity impulse in the movement direction with a transparency effect on the current sprite. I chose not to ship that because the dash would have been a visual compromise, not the mechanic described.

**Shield (K key):** a block mechanic on the key adjacent to attack felt natural, but the required sprite was not available in the pack.

### Progression

**Enemy item drops:** `HealthComponent` already emits `health_depleted` on death — connecting that signal to a drop spawner would be straightforward.

**Health bars:** `health_changed` is emitted on every damage event. A HUD bar just needs to connect to that signal; no changes to the existing components are needed.

### Audio

**Background music** and ambient sound (water, wind, surface-differentiated footsteps).

**Footsteps by surface type:** would require tagging TileMap cells with custom data (`TileData`) to identify terrain type at runtime.

### AI

**Reinforcement-calling behavior:** the original design had the fleeing LimboAI enemy pathfind toward nearby allies and lead them to the player's last known position. It fits naturally as an additional branch in the existing BT, between the Flee action and the SUCCESS that ends that sequence.

---

## Assets

- Sprites: [Tiny Swords — Pixel Frog](https://pixelfrog-assets.itch.io/tiny-swords)
- Audio: [Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds)
