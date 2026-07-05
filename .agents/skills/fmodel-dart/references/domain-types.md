# Domain Type Patterns

Shared **value objects and events** live in `lib/api.dart` — the cross-slice
contract. Each write slice owns its **command**, **errors**, and **state** in
`lib/vertical_slices/<slice>/command.dart`, `errors.dart`, and `state.dart`.

For exhaustive `switch` on sealed types in `decide` and `evolve`, follow
[dart-use-pattern-matching](../../dart-use-pattern-matching/SKILL.md). Run
`dart analyze` to verify exhaustiveness.

## Extension Types for IDs and Value Objects

Use Dart extension types for single-field domain primitives. This maps to
Kotlin `value class` wrappers in the original fmodel examples.

```dart
extension type const RestaurantId._(String value) {
  factory RestaurantId(String raw) {
    if (raw.isEmpty) throw ArgumentError('RestaurantId cannot be empty');
    return RestaurantId._(raw);
  }
}

extension type const OrderId._(String value) {
  factory OrderId(String raw) => OrderId._(raw);
}

extension type const MenuItemPrice._(double value) {
  factory MenuItemPrice(double raw) => MenuItemPrice._(raw);
}
```

Use a ULID or UUID generator at the application boundary for runtime ID
creation — do not use bare strings in handlers.

For multi-field value objects, use regular immutable classes:

```dart
final class MenuItem {
  const MenuItem({
    required this.menuItemId,
    required this.name,
    required this.price,
  });

  final MenuItemId menuItemId;
  final MenuItemName name;
  final MenuItemPrice price;
}

final class RestaurantMenu {
  const RestaurantMenu({
    required this.menuItems,
    required this.menuId,
    required this.cuisine,
  });

  final List<MenuItem> menuItems;
  final RestaurantMenuId menuId;
  final RestaurantMenuCuisine cuisine;
}
```

## Sealed Commands

Commands use sealed class hierarchies with `final class` variants for
exhaustive `switch` matching. Use **switch expressions** in `evolve` (returns a
value) and **switch statements** with `async*` in `decide` (yields events).

```dart
sealed class RestaurantCommand {
  const RestaurantCommand();
}

final class CreateRestaurantCommand extends RestaurantCommand {
  const CreateRestaurantCommand({
    required this.restaurantId,
    required this.name,
    required this.menu,
  });

  final RestaurantId restaurantId;
  final RestaurantName name;
  final RestaurantMenu menu;
}

final class ChangeRestaurantMenuCommand extends RestaurantCommand {
  const ChangeRestaurantMenuCommand({
    required this.restaurantId,
    required this.menu,
  });

  final RestaurantId restaurantId;
  final RestaurantMenu menu;
}
```

For slice-isolated deciders, use a single command class as `C`:

```dart
// create_restaurant_decider.dart handles only CreateRestaurantCommand
Decider<CreateRestaurantCommand, CreateRestaurantState, RestaurantEvent>
```

## Sealed Events

Events use the same sealed hierarchy pattern:

```dart
sealed class RestaurantEvent {
  const RestaurantEvent();
}

final class RestaurantCreatedEvent extends RestaurantEvent {
  const RestaurantCreatedEvent({
    required this.restaurantId,
    required this.name,
    required this.menu,
  });

  final RestaurantId restaurantId;
  final RestaurantName name;
  final RestaurantMenu menu;
}

final class RestaurantMenuChangedEvent extends RestaurantEvent {
  const RestaurantMenuChangedEvent({
    required this.restaurantId,
    required this.menu,
  });

  final RestaurantId restaurantId;
  final RestaurantMenu menu;
}
```

### Multi-Entity Events

Events spanning multiple entities carry all relevant IDs:

```dart
final class RestaurantOrderPlacedEvent extends OrderEvent {
  const RestaurantOrderPlacedEvent({
    required this.restaurantId,
    required this.orderId,
    required this.menuItems,
  });

  final RestaurantId restaurantId;
  final OrderId orderId;
  final List<MenuItem> menuItems;
}
```

Repository `fetchEvents` implementations use these IDs to load the correct
event streams for a command.

## Domain Errors

Prefer throwing typed domain exceptions in `decide` for guard clauses. This
maps directly to Given-When-Then "Then XError is thrown" scenarios.

```dart
sealed class DomainError implements Exception {
  const DomainError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class RestaurantAlreadyExistsError extends DomainError {
  RestaurantAlreadyExistsError(RestaurantId id)
    : super('Restaurant $id already exists');
}

final class RestaurantNotFoundError extends DomainError {
  RestaurantNotFoundError(RestaurantId id)
    : super('Restaurant $id not found');
}
```

Alternative: emit rejection events instead of throwing (as in the fmodel-dart
README restaurant example). Pick one strategy per aggregate and stay consistent.
The restaurant demo requirements use exceptions.

## State Types

Decider state should be minimal — only what `decide` needs for guard clauses:

```dart
final class CreateRestaurantState {
  const CreateRestaurantState({this.restaurantId});

  final RestaurantId? restaurantId;

  bool get exists => restaurantId != null;
}

final class PlaceOrderState {
  const PlaceOrderState({
    this.restaurantId,
    this.menu,
    this.orderPlaced = false,
  });

  final RestaurantId? restaurantId;
  final RestaurantMenu? menu;
  final bool orderPlaced;
}
```

Use `copyWith` for state that evolves across multiple event types.

## Equality

Implement `==` and `hashCode` on state and event classes used in tests.
Extension types inherit equality from their representation type. For sealed event
classes with lists, override equality or use `package:collection` `DeepCollectionEquality`
in test assertions.