# Testing Patterns

Follow [dart-add-unit-test](../../dart-add-unit-test/SKILL.md) for file
structure (`test/` mirrors `lib/`), `group()`, `setUp()`, and async tests.

fmodel-dart provides Given-When-Then test DSLs at two levels. Copy them from the
library into your project's `test/support/` directory:

| DSL file | Source in fmodel_dart | Use for |
| -------- | --------------------- | ------- |
| `decider_test_dsl.dart` | `test/platform/support/` | Pure decider specs |
| `view_test_dsl.dart` | `test/platform/support/` | Pure view specs |
| `decider_test_event_sourced_dsl.dart` | `test/application/support/` | Aggregate + event repo |
| `view_test_dsl.dart` (application) | `test/application/support/` | Ephemeral/materialized views |

## Domain-Level Decider Tests

Test `decide` + `evolve` in isolation — no repository, no I/O.

```dart
import 'package:test/test.dart';
import '../support/decider_test_dsl.dart';

test('PlaceOrder - success', () async {
  await placeOrderDecider
      .givenEvents([restaurantCreatedEvent])
      .whenCommand(placeOrderCommand)
      .thenEvents([orderPlacedEvent]);
});

test('PlaceOrder - restaurant not found', () async {
  await expectLater(
    () => placeOrderDecider
        .givenEvents([])
        .whenCommand(placeOrderCommand)
        .thenEvents([]),
    throwsA(isA<RestaurantNotFoundError>()),
  );
});
```

### `givenState` Variant

When you want to test `decide` from an explicit state without folding events:

```dart
await decider
    .givenState(CreateRestaurantState(restaurantId: RestaurantId('r1')))
    .whenCommand(command)
    .thenState(expectedStateAfterEvents);
```

### Test Coverage Checklist

Each decider test file should cover:

1. **Happy path** — command succeeds, correct events produced
2. **Each guard clause** — one test per domain error
3. **State transitions** — prior events from other use cases affect this
   decider's behavior

## Domain-Level View Tests

Views have no command — use **Given-Then** only.

```dart
import '../support/view_test_dsl.dart';

test('RestaurantView - created', () {
  restaurantView
      .givenEvents([restaurantCreatedEvent])
      .thenState(RestaurantViewState(
        restaurantId: RestaurantId('r1'),
        name: RestaurantName('Italian Bistro'),
        menu: testMenu,
      ));
});

test('RestaurantView - event on null state returns null', () {
  restaurantView
      .givenEvents([menuChangedEvent])
      .thenState(null);
});
```

## Application-Level Aggregate Tests

Integration tests verify the full round-trip through your event repository.

```dart
import '../support/decider_test_event_sourced_dsl.dart';

test('Repository - round trip', () async {
  final repository = CreateRestaurantEventRepository(InMemoryEventStore());
  await createRestaurantDecider
      .givenEventRepository(repository)
      .whenCommand(command)
      .thenEvents([expectedEvent]);
});
```

### Integration Test Pattern

1. Create a fresh in-memory event store (or test database)
2. Create repository and aggregate
3. Execute commands via `aggregate.handle(command)`
4. Query views via `ephemeralView.handle(query)`
5. Assert results
6. Reset store between tests (`deleteAll()` or new instance)

### Locking Repositories

For optimistic concurrency, use the locking DSL:

```dart
await decider
    .givenEventLockingRepository(lockingRepository)
    .whenCommand(command)
    .thenEventPairs([(expectedEvent, 1)]);
```

## Saga and Orchestration Tests

When a saga reacts to events and issues follow-up commands:

```dart
await combinedDecider
    .givenSagaAndEventRepository(saga, repository)
    .whenCommand(command)
    .thenEvents([primaryEvent, sagaFollowUpEvent]);
```

## Property-Based Testing

For invariants across all valid inputs, use a property-based library or
parameterized tests:

```dart
test('creating a restaurant always produces exactly one event', () async {
  for (final name in ['Bistro', 'Cafe', 'Grill']) {
    await createRestaurantDecider
        .givenEvents([])
        .whenCommand(CreateRestaurantCommand(
          restaurantId: RestaurantId('r1'),
          name: RestaurantName(name),
          menu: testMenu,
        ))
        .thenEvents([/* one event with matching name */]);
  }
});
```

### Useful Properties

- **Idempotency**: folding the same event twice yields the same state
- **Completeness**: every valid command on valid state produces events
- **Error coverage**: every invalid command throws the correct domain error
- **View consistency**: folding events equals ephemeral view query result

## Server Handler Tests

Test `lib/server/` handlers without Jaspr — inject in-memory aggregates:

```dart
group('handleCreateRestaurant', () {
  late InMemoryEventStore store;
  late AppServices services;

  setUp(() {
    store = InMemoryEventStore();
    services = AppServices(eventStore: store);
  });

  test('returns events on success', () async {
    final result = await handleCreateRestaurant(
      command: validCommand,
      aggregate: services.createRestaurantAggregate,
    );
    expect(result, isA<HandlerSuccess<List<RestaurantEvent>>>());
  });
});
```

## Running Tests

```bash
dart test                                    # All tests
dart test test/vertical_slices/              # Slice tests only
dart test test/server/                       # Handler tests only
dart test test/vertical_slices/place_order/decider_test.dart  # Single file
dart test --name "PlaceOrder"                # Filter by name
dart analyze                                 # Exhaustiveness checks
```