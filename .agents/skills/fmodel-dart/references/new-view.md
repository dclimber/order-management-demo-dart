# Adding a New Read Model (View + Repository)

Views are pure projections that fold events into queryable read-model state.
fmodel-dart offers two application-layer patterns:

- **EphemeralView** — rebuild state on demand from events (like an event loader)
- **MaterializedView** — persist projected state, update on each event

## 1. Create the View — `lib/vertical_slices/<slice>/view.dart`

```dart
import 'package:fmodel/fmodel.dart';
import 'api.dart';

final class RestaurantViewState {
  const RestaurantViewState({
    required this.restaurantId,
    required this.name,
    required this.menu,
  });

  final RestaurantId restaurantId;
  final RestaurantName name;
  final RestaurantMenu menu;
}

final restaurantView = View<RestaurantViewState?, RestaurantEvent>(
  initialState: null,
  evolve: (state, event) {
    return switch (event) {
      RestaurantCreatedEvent(
        :final restaurantId,
        :final name,
        :final menu,
      ) =>
        RestaurantViewState(
          restaurantId: restaurantId,
          name: name,
          menu: menu,
        ),
      RestaurantMenuChangedEvent(:final menu) =>
        state != null
            ? RestaurantViewState(
                restaurantId: state.restaurantId,
                name: state.name,
                menu: menu,
              )
            : null,
      _ => state,
    };
  },
);
```

### Key Rules for Views

- Views are **pure** — no I/O in `evolve`.
- Initial state is typically `null` (no entity yet).
- When an event arrives on `null` state and cannot initialize, return `null`.
- Use exhaustive `switch` on sealed event types.
- The view's event type parameter `E` should only include events this projection
  handles.

## 2a. Ephemeral View — On-Demand Projection

Use when rebuilding from events on each query is acceptable.

### Repository — `lib/vertical_slices/<slice>/repository.dart`

```dart
import 'package:fmodel/fmodel.dart';
import 'package:order_management_demo/api.dart';

typedef RestaurantViewQuery = RestaurantId;

final class RestaurantEphemeralViewRepository
    implements EphemeralViewRepository<RestaurantEvent, RestaurantViewQuery> {
  RestaurantEphemeralViewRepository(this._store);

  final EventStore _store;

  @override
  Stream<RestaurantEvent> fetchEvents(RestaurantViewQuery query) {
    return _store.streamFor(
      tag: 'restaurantId',
      value: query.value,
      eventTypes: [RestaurantCreatedEvent, RestaurantMenuChangedEvent],
    );
  }
}
```

### Query Handler

```dart
final ephemeralView = createEphemeralView(
  view: restaurantView,
  ephemeralViewRepository: repository,
);

final state = await ephemeralView.handle(RestaurantId('r1'));
// state is RestaurantViewState? 
```

## 2b. Materialized View — Persisted Projection

Use when query latency matters and you can update state on each incoming event.

### Repository — `lib/application/{domain}_view_repository.dart`

```dart
final class RestaurantViewStateRepository
    with ViewStateRepositoryDefaults<RestaurantEvent, RestaurantViewState?>
    implements ViewStateRepository<
      RestaurantEvent,
      RestaurantViewState?,
      NoMetadata
    > {
  @override
  Future<RestaurantViewState?> fetchState(RestaurantCreatedEvent event) async {
    // load current projection state for this entity
  }

  @override
  Future<RestaurantViewState?> save(
    RestaurantEvent event,
    RestaurantViewState? state,
  ) async {
    // persist updated projection
  }
}
```

### Handler

```dart
final materializedView = createMaterializedView(
  view: restaurantView,
  viewStateRepository: repository,
);

final state = await materializedView.handle(restaurantCreatedEvent);
```

## 3. Write Tests

### Domain Unit Test — `test/domain/{domain}_view_test.dart`

Copy `view_test_dsl.dart` from fmodel-dart's `test/domain/support/`.

```dart
import 'package:test/test.dart';
import '../support/view_test_dsl.dart';

void main() {
  test('RestaurantView - created', () {
    restaurantView
        .givenEvents([restaurantCreatedEvent])
        .thenState(RestaurantViewState(
          restaurantId: RestaurantId('r1'),
          name: RestaurantName('Italian Bistro'),
          menu: testMenu,
        ));
  });

  test('RestaurantView - menu changed on null returns null', () {
    restaurantView
        .givenEvents([menuChangedEvent])
        .thenState(null);
  });
}
```

### Application Integration Test

```dart
test('EphemeralView - project from store', () async {
  final repository = RestaurantEphemeralViewRepository(store);
  await repositoryView
      .givenEphemeralRepository(repository)
      .whenQuery(RestaurantId('r1'))
      .thenState(expectedState);
});
```

## 4. Expose via Jaspr SSR Page

Query read models on the server with `AsyncStatelessComponent`. Import
`package:jaspr/server.dart` only in page files.

```dart
class RestaurantPage extends AsyncStatelessComponent {
  const RestaurantPage({required this.restaurantId, super.key});

  final String restaurantId;

  @override
  Future<Component> build(BuildContext context) async {
    final state = await appServices.restaurantView(
      RestaurantId(restaurantId),
    );
    if (state == null) return section([.text('Restaurant not found')]);

    return section(classes: 'restaurant', [
      h1([.text(state.name.value)]),
      // render menu items
    ]);
  }
}
```

For dashboards that need client refresh (e.g., kitchen order list), pass
serialized view state into a single `@client` component. See
[jaspr-integration.md](jaspr-integration.md).

## Checklist

- [ ] View created in `lib/domain/{domain}_view.dart`
- [ ] Ephemeral or materialized repository in `lib/application/`
- [ ] Query method on `AppServices` composition root
- [ ] Domain unit tests with `givenEvents().thenState()`
- [ ] Application integration tests
- [ ] SSR page in `lib/pages/` (and route in `lib/app.dart`)
- [ ] All tests pass: `dart test`