# Adding a New Slice (Decider + Repository + Aggregate)

This guide walks through adding a complete slice. Replace `{Command}` with your
command name (e.g., `CancelOrder`).

## 0. Write Given-When-Then Requirements

Before writing any code, create a `REQUIREMENTS-{UseCase}.md` document.

See [requirements-gwt.md](requirements-gwt.md) for the full template.

At minimum:

- Description of the use case
- Input events table (what the repository loads)
- Output events table (what the decider produces)
- One scenario per behavior path (happy path + one per domain error)
- Domain errors table
- State shape

## 1. Define Slice Types

Add shared VOs/events to `lib/api.dart` when needed across slices. Add
command, errors, and state to `lib/vertical_slices/<slice>/` as described in
[domain-types.md](domain-types.md).

## 2. Create the Decider — `lib/vertical_slices/<slice>/decider.dart`

A decider is a pure pair: `decide` (command + state → `Stream<events>`) and
`evolve` (state + event → state).

```dart
import 'package:fmodel/fmodel.dart';
import 'api.dart';

final createRestaurantDecider =
    Decider<CreateRestaurantCommand, CreateRestaurantState, RestaurantEvent>(
  initialState: const CreateRestaurantState(),
  decide: (command, state) async* {
    if (state.exists) {
      throw RestaurantAlreadyExistsError(command.restaurantId);
    }
    yield RestaurantCreatedEvent(
      restaurantId: command.restaurantId,
      name: command.name,
      menu: command.menu,
    );
  },
  evolve: (state, event) {
    return switch (event) {
      RestaurantCreatedEvent(:final restaurantId) =>
        CreateRestaurantState(restaurantId: restaurantId),
      _ => state,
    };
  },
);
```

### Key Rules for Deciders

- **`decide` returns `Stream<E>`** — use `async*` and `yield` for events.
- **Input events** are folded into state before `decide` runs (by
  `EventComputation.computeNewEvents`). The decider's `evolve` must handle all
  event types the repository loads.
- **Output events** are what `decide` yields for the current command.
- **`decide` and `evolve` are pure** — no I/O, no repository calls.
- **State is minimal** — only fields needed for guard clauses in `decide`.
- Use exhaustive `switch` on sealed types; add a wildcard `_` only for
  cross-slice deciders that ignore unrelated events.

### Cross-Boundary Slices

When a slice reads events from multiple entities (like `PlaceOrder`), the
decider's `evolve` handles all input event types and the repository's
`fetchEvents` loads streams for each entity:

```dart
@override
Stream<RestaurantEvent> fetchEvents(PlaceOrderCommand command) async* {
  yield* _restaurantEvents(command.restaurantId);
  yield* _orderEvents(command.orderId);
}
```

## 3. Create the Repository — `lib/vertical_slices/<slice>/repository.dart`

Implement `EventRepository<C, E, CM, EM>`. Use `EventRepositoryDefaults` mixin
for metadata boilerplate.

```dart
import 'package:fmodel/fmodel.dart';
import 'package:order_management_demo/api.dart';

final class CreateRestaurantEventRepository
    with EventRepositoryDefaults<CreateRestaurantCommand, RestaurantEvent>
    implements EventRepository<
      CreateRestaurantCommand,
      RestaurantEvent,
      NoMetadata,
      NoMetadata
    > {
  CreateRestaurantEventRepository(this._store);

  final EventStore _store;

  @override
  Stream<RestaurantEvent> fetchEvents(CreateRestaurantCommand command) {
    return _store.streamFor(
      tag: 'restaurantId',
      value: command.restaurantId.value,
      eventTypes: [RestaurantCreatedEvent],
    );
  }

  @override
  Stream<RestaurantEvent> save(Stream<RestaurantEvent> events) {
    return _store.append(events);
  }
}
```

### Event Loading Contract

`fetchEvents(command)` defines the slice's consistency boundary:

- Load all events needed to reconstruct state for the decision
- Return events in chronological order
- Tag/index strategy is implementation-specific (in-memory list, SQLite, etc.)

## 4. Wire the Aggregate

```dart
EventSourcingAggregate<
  CreateRestaurantCommand,
  CreateRestaurantState,
  RestaurantEvent,
  NoMetadata,
  NoMetadata
> createRestaurantAggregate({
  required EventRepository<
    CreateRestaurantCommand,
    RestaurantEvent,
    NoMetadata,
    NoMetadata
  > repository,
}) {
  return createEventSourcingAggregate(
    decider: createRestaurantDecider,
    eventRepository: repository,
  );
}
```

Handle commands:

```dart
final events = await aggregate
    .handle(command)
    .toList();
```

## 5. Write Decider Tests — `test/vertical_slices/<slice>/decider_test.dart`

Copy the test DSL from fmodel-dart's `test/domain/support/decider_test_dsl.dart`
into your project's `test/platform/support/` folder.

```dart
import 'package:test/test.dart';
import '../../platform/support/decider_test_dsl.dart';
import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/decider.dart';

void main() {
  test('CreateRestaurant - success', () async {
    const command = CreateRestaurantCommand(
      restaurantId: RestaurantId('r1'),
      name: RestaurantName('Italian Bistro'),
      menu: testMenu,
    );

    await createRestaurantDecider
        .givenEvents([])
        .whenCommand(command)
        .thenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('r1'),
            name: RestaurantName('Italian Bistro'),
            menu: testMenu,
          ),
        ]);
  });

  test('CreateRestaurant - already exists', () async {
    await expectLater(
      () => createRestaurantDecider
          .givenEvents([existingRestaurantCreatedEvent])
          .whenCommand(command)
          .thenEvents([]),
      throwsA(isA<RestaurantAlreadyExistsError>()),
    );
  });
}
```

## 6. Write Repository Tests — `test/vertical_slices/<slice>/repository_test.dart`

Copy the application test DSL from
`fmodel-dart/test/application/support/decider_test_event_sourced_dsl.dart` into
`test/platform/support/`.

```dart
test('Repository - round trip', () async {
  final repository = CreateRestaurantEventRepository(InMemoryEventStore());
  final aggregate = createRestaurantAggregate(repository: repository);

  final events = await aggregate.handle(command).toList();
  expect(events, hasLength(1));
});
```

## 7. Create Server Handler — `lib/vertical_slices/<slice>/handler.dart`

Keep handlers as plain Dart — testable without Jaspr. See
[jaspr-integration.md](jaspr-integration.md).

```dart
Future<HandlerResult<List<RestaurantEvent>>> handleCreateRestaurant({
  required CreateRestaurantCommand command,
  required CreateRestaurantAggregate aggregate,
}) async {
  try {
    final events = await aggregate.handle(command).toList();
    return HandlerSuccess(events);
  } on RestaurantAlreadyExistsError catch (e) {
    return HandlerError(409, e.toString());
  }
}
```

Write handler tests in `test/vertical_slices/<slice>/handler_test.dart`.

## 8. Wire Jaspr UI

1. Register API route pointing to the handler (see [jaspr-integration.md](jaspr-integration.md))
2. Add `@client` form in `lib/vertical_slices/<slice>/ui/` that POSTs to the API
3. Add SSR section in slice `ui/` or composite page in `lib/shell/pages/`
4. Register slice in `lib/composition/slice_registry.dart` and route in `lib/shell/app.dart`

Follow [jaspr-fundamentals](../../jaspr-fundamentals/SKILL.md) for components and
[jaspr-pre-rendering-and-hydration](../../jaspr-pre-rendering-and-hydration/SKILL.md)
for `@client` / `AsyncStatelessComponent` rules.

## Checklist

- [ ] Requirements written in `doc/REQUIREMENTS-{UseCase}.md` with GWT scenarios
- [ ] Shared VOs/events added to `lib/api.dart` when cross-slice
- [ ] Command/errors/state in `lib/vertical_slices/<slice>/`
- [ ] Decider, repository, aggregate in `lib/vertical_slices/<slice>/`
- [ ] Decider + repository tests in `test/vertical_slices/<slice>/`
- [ ] Handler in slice with handler tests
- [ ] API route + `@client` form or SSR page wired via `module.dart`
- [ ] Slice registered in `lib/composition/slice_registry.dart`
- [ ] All tests pass: `dart test`