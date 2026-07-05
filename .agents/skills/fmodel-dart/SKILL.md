---
name: fmodel-dart
description: >-
  Build event-sourced applications using the fmodel Dart library with Decider,
  View, EventSourcingAggregate, EphemeralView, and MaterializedView patterns.
  Use when creating deciders, repositories, views, domain types, sealed
  commands/events, extension-type IDs, Given-When-Then tests, or Jaspr routes
  and components for an event-sourced domain.
compatibility: >-
  Dart SDK ^3.10.0. Requires package:fmodel (fmodel_dart). This project uses
  Jaspr server mode (^0.23.1). package:test for specification tests.
metadata:
  version: "1.1.0"
  package: order_management_demo
  jaspr_version: 0.23.1
  jaspr_mode: server
  spec-source: https://github.com/dclimber/fmodel_dart
---

# fmodel Dart Skill

You are building **order_management_demo** — an event-sourced restaurant and
order management application using **fmodel** for Dart on **Jaspr server mode**.

## Related Skills

Load these sibling skills when their concerns arise:

| Skill | Use when |
| ----- | -------- |
| [jaspr-fundamentals](../jaspr-fundamentals/SKILL.md) | Components, HTML elements, events, `@client` basics |
| [jaspr-pre-rendering-and-hydration](../jaspr-pre-rendering-and-hydration/SKILL.md) | SSR pages, `AsyncStatelessComponent`, hydration, dual entrypoints |
| [jaspr-styling](../jaspr-styling/SKILL.md) | `@css`, layout, themes, dashboard styling |
| [dart-use-pattern-matching](../dart-use-pattern-matching/SKILL.md) | Sealed commands/events, exhaustive `switch` in deciders |
| [dart-add-unit-test](../dart-add-unit-test/SKILL.md) | `group()`, `setUp()`, async tests, matchers |

## Key Concept: Slice = Command = Use Case

The fundamental unit of work is a **slice**. These three terms are
interchangeable:

- **Slice** — a vertical slice through the system handling one command
- **Command** — the command type the slice handles
- **Use case** — the business capability the slice implements

Each slice gets its own requirements doc, decider logic, repository wiring, and
tests. A slice defines its consistency boundary by declaring which events the
repository loads before `decide` runs — it can span multiple entities (e.g.,
`PlaceOrder` reads both restaurant and order events).

Examples: `CreateRestaurant`, `PlaceOrder`, `MarkOrderAsPrepared` are each a
slice.

> **fmodel-dart vs fmodel-decider (TypeScript):** The TypeScript
> `fmodel-decider` library enforces one-command deciders via `DcbDecider`. In
> Dart, `Decider<C, S, E>` accepts a command supertype `C` and may handle
> multiple commands. For slice isolation, implement **one decider per slice**
> (single command type) or isolate command handling via exhaustive `switch` on
> sealed command classes. See [dart-use-pattern-matching](../dart-use-pattern-matching/SKILL.md).

## Core Principles

1. **Requirements as Given-When-Then / Given-Then scenarios**: every slice
   starts with a `doc/REQUIREMENTS-{Command}.md` document. Each scenario becomes
   one executable test. Write requirements first, then tests, then implement.
2. **Type system as formal specification**: `DeciderContract`, `ViewContract`,
   `EventRepository`, and `EventSourcingAggregate` constrain implementations.
   Sealed classes + exhaustive `switch` make invalid branches compile errors.
3. **Pure domain logic**: deciders and views have no I/O. Side effects live in
   repositories and server handlers only.
4. **Extension types for IDs**: single-field domain primitives (IDs, prices).
5. **Sealed class hierarchies**: commands and events with `final class` variants.
6. **Immutable domain models**: `final` fields, `const` constructors, `copyWith`.
7. **Snapshot-style events**: each event carries full state for its dimension.

## Vertical Slice Architecture (Jaspr Server Mode)

```
┌─────────────────────────────────────────────────────────────┐
│  lib/shell/              SSR pages, header, theme, chrome     │
│  lib/vertical_slices/*/ui/   @client forms + SSR sections   │
├─────────────────────────────────────────────────────────────┤
│  lib/composition/        ApiRegistry, AppServices facade      │
│  lib/vertical_slices/*/  command, decider, handler, repo, dto │
├─────────────────────────────────────────────────────────────┤
│  lib/api.dart            Shared VOs + events (immutable facts)│
│  lib/platform/           event store, db, auth, server helpers│
└─────────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
   Event store (server)          fmodel EventSourcingAggregate
```

**Import rules**:

- `lib/api.dart` — VOs and events only; imported across slices
- `lib/vertical_slices/<slice>/` — no cross-slice imports except `api.dart` and `platform/`
- `lib/platform/` — shared kernel; no slice-specific logic
- `lib/shell/` and slice `ui/` with `@client` — compile for server **and** client;
  call APIs via `fetch` rather than importing repositories directly

## Architecture Overview

```
Commands ──► Decider (decide + evolve) ──► Stream<Events>
                                              │
                                              ▼
Events ──► View (evolve) ──► Read Model State
                                              │
                                              ▼
Events ──► EventRepository ──► Event Store
```

```
Command ──► EventSourcingAggregate.handle(command)
              ├─ fetchEvents(command)
              ├─ computeNewEvents(...)
              └─ save(newEvents)
```

## When to Use This Skill

- Writing **Given-When-Then requirements** for a new slice
- Adding a new **slice** (requirements + decider + repository + tests)
- Adding a new **read model** (view + ephemeral/materialized repository)
- Defining **domain types** (sealed commands/events, extension-type IDs)
- Creating **server API handlers** that dispatch commands
- Building **Jaspr pages** (SSR queries) and **@client components** (forms)
- Writing **specification tests** with the fmodel test DSL

## File Naming Conventions

| Artifact               | Pattern                              | Location        |
| ---------------------- | ------------------------------------ | --------------- |
| Slice requirements     | `REQUIREMENTS-{Command}.md`          | `doc/`          |
| View requirements      | `REQUIREMENTS-VIEW-{View}.md`        | `doc/`          |
| Shared VOs + events    | `api.dart`                           | `lib/`          |
| Command / errors / state | `command.dart`, `errors.dart`, `state.dart` | `lib/vertical_slices/<slice>/` |
| Decider (per slice)    | `decider.dart`                       | `lib/vertical_slices/<slice>/` |
| Repository (per slice) | `repository.dart`                    | `lib/vertical_slices/<slice>/` |
| Server handler         | `handler.dart`                       | `lib/vertical_slices/<slice>/` |
| View (read slice)      | `view.dart`                          | `lib/vertical_slices/<slice>/` |
| Slice registration     | `module.dart`                        | `lib/vertical_slices/<slice>/` |
| Slice unit tests       | `decider_test.dart`, `handler_test.dart`, etc. | `test/vertical_slices/<slice>/` |
| Shared contract tests  | `api_test.dart`                      | `test/`         |
| Composition tests      | `app_services_test.dart`             | `test/composition/` |
| Test DSL helpers       | `decider_test_dsl.dart`, etc.        | `test/platform/support/` |
| Jaspr pages (SSR)      | `{feature}.dart`                     | `lib/shell/pages/` |
| Jaspr components       | `{name}.dart`                        | `lib/shell/components/` or slice `ui/` |

Register new pages in `lib/shell/app.dart` via `jaspr_router`:

```dart
Route(path: '/kitchen', title: 'Kitchen', builder: (context, state) => const Kitchen()),
```

## Workflow: Requirements → Tests → Implementation

1. **Write requirements** → `doc/REQUIREMENTS-{CommandName}.md`
2. **Decider tests** → `test/vertical_slices/<slice>/decider_test.dart`
3. **Decider** → `lib/vertical_slices/<slice>/decider.dart`
4. **Repository + aggregate** → `lib/vertical_slices/<slice>/`
5. **Server handler** → `lib/vertical_slices/<slice>/handler.dart` (testable without Jaspr)
6. **Jaspr UI** → `lib/vertical_slices/<slice>/ui/` + `lib/shell/pages/` (see jaspr-integration.md)

See [references/requirements-gwt.md](references/requirements-gwt.md).

Example requirements (restaurant domain — adapt to your domain):

- [references/REQUIREMENTS-CreateRestaurant.md](references/REQUIREMENTS-CreateRestaurant.md)
- [references/REQUIREMENTS-ChangeRestaurantMenu.md](references/REQUIREMENTS-ChangeRestaurantMenu.md)
- [references/REQUIREMENTS-PlaceOrder.md](references/REQUIREMENTS-PlaceOrder.md)
- [references/REQUIREMENTS-MarkOrderAsPrepared.md](references/REQUIREMENTS-MarkOrderAsPrepared.md)

## Step-by-Step Guides

- [references/new-slice.md](references/new-slice.md) — decider + repository + handler
- [references/new-view.md](references/new-view.md) — ephemeral/materialized views
- [references/jaspr-integration.md](references/jaspr-integration.md) — SSR pages, @client forms, API
- [references/domain-types.md](references/domain-types.md) — extension types, sealed classes
- [references/testing.md](references/testing.md) — Given-When-Then test DSL

## Common Commands

```bash
dart pub get
dart analyze
dart format .
dart test
dart test test/vertical_slices/create_restaurant/decider_test.dart
dart run build_runner build --delete-conflicting-outputs   # Jaspr codegen
jaspr serve                                                 # Dev server
```

## Package Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  fmodel:
    git:
      url: https://github.com/dclimber/fmodel_dart
      ref: main
  jaspr: ^0.23.1
  jaspr_router: ^0.8.2

dev_dependencies:
  test: ^1.26.0
  jaspr_builder: ^0.23.1
  build_runner: ^2.10.0

jaspr:
  mode: server
```

```dart
import 'package:fmodel/fmodel.dart';
```

## Reference Implementations

- [dclimber/fmodel_dart](https://github.com/dclimber/fmodel_dart) — library,
  test DSL in `test/platform/support/`
- [fraktalio/order-management-demo](https://github.com/fraktalio/order-management-demo)
  — restaurant domain behavior (TypeScript/Deno; port requirements to Dart)