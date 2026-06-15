# Prueba Técnica Sekidan — Top-Down 2D (Godot 4)

Demo de combate top-down 2D construida en Godot 4 como parte de la evaluación técnica de Sekidan Games.

El proyecto implementa control del jugador mediante FSM, dos tipos de enemigos con comportamientos distintos (uno basado en FSM y otro en Behavior Tree con LimboAI), tres componentes de combate reutilizables, y un conjunto de efectos de game feel que hacen el combate más satisfactorio.

---

## Cómo ejecutar

1. Descargar e instalar **Godot 4.6.3** (el proyecto fue desarrollado en esta versión; 4.6.2 debería funcionar también — la diferencia es de parche menor y está documentada aquí).
2. Clonar o descargar el repositorio.
3. Abrir Godot, hacer clic en **Importar** y seleccionar el archivo `project.godot`.
4. El addon **LimboAI v1.7.1** ya está incluido en `addons/limboai/` — no requiere instalación adicional.
5. Presionar **F5** para ejecutar. La escena principal es `world.tscn`.

---

## Controles

| Tecla | Acción |
|-------|--------|
| W / A / S / D | Mover |
| J | Atacar (direccional — 4 direcciones, alterna entre 2 animaciones) |

---

## Qué se implementó

### Jugador

`CharacterBody2D` controlado mediante una **Finite State Machine** con 5 estados: `Idle`, `Walk`, `Attack`, `Hurt`, `Dead`.

**Sistema de ataque direccional.** La animación y la posición del hitbox se determinan por la última dirección de movimiento registrada. Cada dirección soporta dos variantes de animación que alternan en cada ataque (`attack_1`/`attack_2`, `attack_up1`/`attack_up2`, `attack_down1`/`attack_down2`), lo que da variedad visual sin duplicar lógica.

**Efectos de game feel implementados:**

- **Hit-stop:** al conectar un golpe, `Engine.time_scale` se congela en `0.0` durante 80ms. El timer de descongelamiento usa `process_always = true` para ignorar el time_scale y reactivarse correctamente.
- **Screen shake:** temblor de cámara mediante Tween con 8 pasos de decaimiento progresivo. Se dispara tanto al aterrizar un golpe como al recibir daño.
- **Estela de ataque:** nodo `GPUParticles2D` hijo de `HitboxComponent`, activado exactamente en el frame de impacto junto con el hitbox.
- **Knockback:** impulso de velocidad calculado desde la dirección del golpe, aplicado en `_on_damage_received`. Decae suavemente en el estado `Hurt` mediante `move_toward`.
- **Flash al recibir daño:** modulación de color rojo en el sprite al entrar al estado `Hurt`, revertida con Tween.
- **Audio:** sonido distinto al golpear y al recibir daño.

**Muerte:** al entrar al estado `Dead`, se desactiva el proceso de física, se deshabilita el `HurtboxComponent` y se deshabilita la `CollisionShape2D` con `set_deferred` para evitar errores dentro del callback de física. El jugador queda completamente inerte.

---

### Enemigo — FSM (`actors/enemy/`)

`CharacterBody2D` con una **Finite State Machine** de 5 estados: `Patrol`, `Chase`, `Attack`, `Hurt`, `Dead`.

- **Detección por señales:** el rango de detección usa `Area2D` con `body_entered` / `body_exited`. No hay polling de distancia por frame: el estado `player_detected` se actualiza solo cuando el jugador entra o sale del área.
- **Hitbox direccional:** la posición del hitbox se espeja según `sprite.flip_h` (`HITBOX_OFFSET_X = 35px`).
- **Frame-accurate hit window:** el hitbox se activa en el frame 3 de 6 de la animación de ataque, conectando directamente `frame_changed` a la lógica de activación.
- **Cooldown de ataque:** 1.5s gestionado mediante un contador en `_physics_process`, sin timers separados.
- Knockback, flash de daño, audio en cada evento de combate y limpieza completa de colisiones al morir.

---

### Enemigo — Behavior Tree (`actors/enemy_limbo/`)

`CharacterBody2D` impulsado por **LimboAI v1.7.1** (GDExtension).

**Estructura del Behavior Tree** — raíz `BTSelector`, re-evaluada desde el inicio en cada frame:

```
BTSelector
├── BTSequence  →  BTConditionLowHealth      + BTActionFlee
├── BTSequence  →  BTConditionPlayerInAttackRange  + BTActionAttack
├── BTSequence  →  BTConditionPlayerDetected  + BTActionChase
└── BTActionPatrol  (fallback)
```

| Comportamiento | Condición de activación | Detalle |
|---|---|---|
| **Huir** (prioridad máxima) | Vida < 30% | Se aleja a 120px/s hasta mantener 200px de distancia |
| **Atacar** | Jugador dentro de 60px | Frame-accurate hit window, cooldown 1.5s |
| **Perseguir** | Jugador detectado (< 235px) | 80px/s hacia el jugador |
| **Patrullar** (fallback) | Siempre | Oscila 120px izquierda/derecha desde el origen |

**7 tasks custom en GDScript** (`actors/enemy_limbo/tasks/`):
- Condiciones: `BTConditionLowHealth`, `BTConditionPlayerDetected`, `BTConditionPlayerInAttackRange`
- Acciones: `BTActionFlee`, `BTActionAttack`, `BTActionChase`, `BTActionPatrol`

> **Nota de implementación — prioridad reactiva:** `BTActionPatrol` devuelve `SUCCESS` en lugar de `RUNNING`. Un `BTSelector` estándar se congela en el hijo en `RUNNING` y no re-evalúa las ramas de mayor prioridad hasta que ese hijo termine. Al devolver `SUCCESS`, el Selector completa el tick y vuelve a evaluar desde la raíz en el siguiente frame — lo que permite que Huir interrumpa inmediatamente la patrulla cuando la vida cae, sin necesitar un `DynamicSelector` ni ninguna señal adicional.

---

### Componentes reutilizables (`actors/player/`)

Los tres componentes están completamente desacoplados — no hacen ninguna suposición sobre el tipo de su nodo padre y se pueden agregar a cualquier actor sin modificaciones.

**`HealthComponent`** (`extends Node`)
Gestiona `current_health` y `max_health`. Emite `health_changed(new_health: float)` en cada evento de daño y `health_depleted` cuando la vida llega a cero.

**`HitboxComponent`** (`extends Area2D`)
Expone `damage: float` y `set_active(bool)`. Emite `hit_landed` al conectar un golpe (usado para disparar screen shake y audio en el atacante). Importante: `set_active()` setea `monitoring` directamente y envuelve `monitorable` con `set_deferred()` — ver Notas de arquitectura.

**`HurtboxComponent`** (`extends Area2D`)
Escucha solapamientos con `HitboxComponent`, filtra auto-golpes (`hitbox.owner == owner`), calcula la dirección del golpe, notifica al hitbox con `notify_hit()` y emite `damage_received(amount: float, direction: Vector2)`.

---

### Mapa

Construido con **TileMapLayers** separadas por función: `suelo`, `cesped_suelo`, `suelo_up`, `cesped_suelo_up`, `bridge`, `decoracion`. Las colisiones físicas (paredes, agua, obstáculos) están en una capa dedicada `Colisiones_map`, desacoplada del renderizado.

---

## Capas de colisión

| Capa | Bit | Usado por |
|------|-----|-----------|
| 1 | 1 | Cuerpo del jugador + tiles del mapa |
| 2 | 2 | `HitboxComponent` del jugador |
| 3 | 4 | `HurtboxComponent` del jugador |
| 4 | 8 | Cuerpo del enemigo (FSM + LimboAI) |
| 5 | 16 | `HitboxComponent` del enemigo |
| 6 | 32 | `HurtboxComponent` del enemigo |
| 7 | 64 | `DetectionRange` del enemigo (mask → capa 1) |

Los cuerpos del jugador y los enemigos no colisionan entre sí — esto permite superposición física mientras mantiene la detección hitbox/hurtbox completamente funcional.

---

## Estructura del proyecto

```
actors/
├── player/          # Escena del jugador, estados FSM, componentes compartidos
│   ├── player.gd / player.tscn
│   ├── states.gd              # Clase base PlayerState
│   ├── idle.gd / walk.gd / attack.gd / hurt.gd / dead.gd
│   ├── health_component.gd
│   ├── hitbox_component.gd
│   ├── hurtbox_component.gd
│   └── attack_trail.gd
├── enemy/           # Enemigo con FSM
│   ├── enemy.gd / enemy.tscn
│   ├── enemy_state.gd         # Clase base EnemyState
│   └── patrol.gd / chase.gd / attack.gd / hurt.gd / dead.gd
└── enemy_limbo/     # Enemigo con Behavior Tree (LimboAI)
    ├── enemy_limbo.gd / enemy_limbo.tscn
    └── tasks/
        ├── bt_condition_low_health.gd
        ├── bt_condition_player_detected.gd
        ├── bt_condition_player_in_attack_range.gd
        ├── bt_action_flee.gd
        ├── bt_action_attack.gd
        ├── bt_action_chase.gd
        └── bt_action_patrol.gd
assets/              # Sprites y audio
addons/limboai/      # LimboAI v1.7.1 GDExtension (incluido en el repo)
world.tscn           # Escena principal
```

---

## Notas de arquitectura

### Por qué `set_active()` y no `monitoring` directo

En Godot 4, modificar `monitorable` en un `Area2D` dentro de un callback de señal de área (`area_entered`, `body_entered`) genera el error `"Function blocked during in/out signal"`. La solución es separar las dos propiedades: `monitoring` se puede setear directamente (es seguro fuera de la física), pero `monitorable` siempre debe diferirse con `set_deferred()`. `HitboxComponent.set_active(bool)` encapsula exactamente eso, y es la única forma de activar o desactivar el hitbox en todo el proyecto.

### Por qué FSM para el jugador y el enemigo básico, pero BT para el enemigo LimboAI

El jugador y el enemigo básico tienen un flujo de estados pequeño y lineal: las transiciones son directas y predecibles. Una FSM es más simple, más legible y más fácil de debuggear para ese caso.

El enemigo LimboAI necesita un cuarto comportamiento — huir — que debe poder interrumpir cualquiera de los otros tres en tiempo de ejecución basándose en una condición de umbral (vida < 30%). Implementar eso en una FSM requeriría agregar checks de `is_low_health()` al inicio de cada estado, o una capa de "estado de emergencia" que complica la lectura. Un Behavior Tree resuelve eso de forma nativa con prioridades: la rama de mayor prioridad siempre se evalúa primero.

### Por qué `BTActionPatrol` devuelve `SUCCESS` y no `RUNNING`

Un `BTSelector` estándar detiene la evaluación del tick cuando encuentra un hijo en `RUNNING` y no re-evalúa las ramas superiores hasta que ese hijo termine o falle. Si `BTActionPatrol` devolviera `RUNNING`, el enemigo patrullaría indefinidamente y nunca vería al jugador aparecer (las condiciones de Huir, Atacar y Perseguir nunca se evaluarían). Devolviendo `SUCCESS`, el Selector completa el tick en cada frame y re-evalúa desde la raíz, lo que da prioridad reactiva real sin necesitar un `DynamicSelector` ni ningún tipo de señal de interrupción.

### Por qué los componentes viven en `actors/player/`

Los tres componentes son compartidos por todos los actores. Se desarrollaron junto al jugador y se mantuvieron ahí para evitar una carpeta `components/` extra en un proyecto de este tamaño. En una codebase más grande tendrían su propia carpeta de nivel superior.

### Instalación de LimboAI

La build disponible en la Asset Library de Godot 4.6 solo incluía binarios para macOS. El addon se instaló manualmente desde la [página de releases de GitHub](https://github.com/limbonaut/limboai/releases) usando el build `gdextension` para Godot 4.6. Está commiteado en el repo, por lo que no requiere ningún paso adicional al abrir el proyecto.

---

## Proceso de desarrollo

Este proyecto fue mi primer contacto real con Godot. Antes de empezar, tenía experiencia en programación en general pero no había trabajado con el engine.

El desarrollo arrancó desde lo más básico: entender cómo funciona el árbol de nodos, cómo se conectan las señales, y por qué GDScript tiene ciertas restricciones que otros lenguajes no tienen (como el comportamiento de `monitorable` dentro de callbacks). Cada decisión técnica que está en este proyecto fue investigada, implementada, y en muchos casos rota y reconstruida desde cero hasta entender por qué funcionaba.

A mitad de camino hubo una limpieza total del proyecto — la deuda técnica se acumuló lo suficiente como para que fuera más eficiente empezar de nuevo que seguir parcheando. Esa decisión fue deliberada y aceleró la parte final del desarrollo.

El enemigo FSM fue el primer componente en funcionar correctamente. Después vino el jugador completo con todos los efectos de game feel. El enemigo LimboAI fue lo último en implementarse, una vez que ya había claridad suficiente sobre cómo funcionan los componentes y cómo estructurar el árbol de comportamiento.

LimboAI tuvo una fricción extra de setup: la versión de la Asset Library no incluía binarios para Windows en Godot 4.6.3, así que hubo que instalarla manualmente desde GitHub, leer la documentación del addon y entender el ciclo `_enter` / `_tick` / `_exit` de las tasks antes de poder escribir la primera condición.

Lo que más tiempo tomó no fue escribir código — fue entender cuándo Godot espera que una operación se difiera al final del frame, cuándo una señal puede o no modificar el árbol de nodos, y cómo diseñar los componentes para que no asumieran nada sobre su contexto. Esas restricciones terminaron dando forma a buena parte de la arquitectura final.

---

## Qué agregaría con más tiempo

### Combate

**Esquive (tecla H):** el enunciado contemplaba una voltereta con ventana de invencibilidad. Se descartó porque el spritesheet de Tiny Swords no incluye un ciclo de animación de roll. Una alternativa técnica válida habría sido un dash — impulso de velocidad en la dirección de movimiento con un efecto de transparencia sobre el sprite actual. Opté por no hacerlo porque el dash habría sido un compromiso visual, no la mecánica pedida.

**Escudo (tecla K):** mecánica de bloqueo natural para la tecla adyacente al ataque, pero el sprite necesario no estaba disponible en el pack.

### Progresión

**Drops de enemigos:** `HealthComponent` ya emite `health_depleted` al morir — conectar esa señal a un spawner de items sería directo.

**Barras de vida:** `health_changed` se emite en cada evento de daño. Una barra de HUD solo necesita conectarse a esa señal; no requiere ningún cambio en los componentes existentes.

### Audio

**Música de fondo** y sonido ambiental (agua, viento, pisadas diferenciadas por superficie).

**Pisadas por tipo de superficie:** requeriría etiquetar las celdas del TileMap con datos custom (`TileData`) para identificar el tipo de terreno en tiempo de ejecución.

### IA

**Comportamiento de llamada de refuerzos:** el diseño original tenía al enemigo LimboAI en huida navegando hacia aliados cercanos y llevándolos a la última posición conocida del jugador. Encaja naturalmente como una rama adicional en el BT existente, entre la acción de Huir y el SUCCESS que termina esa secuencia.

---

## Assets

- Sprites: [Tiny Swords — Pixel Frog](https://pixelfrog-assets.itch.io/tiny-swords)
- Audio: [Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds)
