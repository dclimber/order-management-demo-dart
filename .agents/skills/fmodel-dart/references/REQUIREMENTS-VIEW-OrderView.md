# Requirements: OrderView

> **Domain example**: This is from a restaurant management domain. Adapt the
> patterns and structure to your own domain.

View: `orderView` Type: `View<OrderViewState?, OrderEvent>`

## Description

A read-model projection that builds a denormalized order state from
order-related events. Tracks order details and lifecycle status (CREATED →
PREPARED).

## Input Events

| Event                        | Purpose                       |
| ---------------------------- | ----------------------------- |
| `RestaurantOrderPlacedEvent` | Initialize order state        |
| `OrderPreparedEvent`         | Transition status to PREPARED |

## View State Shape

```dart
// OrderViewState? — null when no order exists yet
final class OrderViewState {
  final OrderId orderId;
  final RestaurantId restaurantId;
  final List<MenuItem> menuItems;
  final OrderStatus status; // created | prepared
}
```

- `null` → no order placed yet (initial state)

## Scenarios

Views use **Given-Then** format (no "When" — there is no command, only events
folded into state).

### Scenario 1: Order placed

```gherkin
Given RestaurantOrderPlacedEvent occurred
  with orderId "order-1"
  and restaurantId "restaurant-1"
  and menuItems [Pizza ($10.00)]
Then view state is
  orderId "order-1"
  restaurantId "restaurant-1"
  menuItems [Pizza ($10.00)]
  status "CREATED"
```

### Scenario 2: Order prepared

```gherkin
Given RestaurantOrderPlacedEvent occurred
  with orderId "order-1"
  and restaurantId "restaurant-1"
  and menuItems [Pizza ($10.00)]
And OrderPreparedEvent occurred
  with orderId "order-1"
Then view state is
  orderId "order-1"
  restaurantId "restaurant-1"
  menuItems [Pizza ($10.00)]
  status "PREPARED"
```

### Scenario 3: Prepared event without prior order (null state)

```gherkin
Given OrderPreparedEvent occurred
  with orderId "order-1"
Then view state is null
```

## Key Design Decisions

- Prepared event on null state returns null (no partial state creation)
- Status transitions: `CREATED` → `PREPARED` (one-way lifecycle)
- The view preserves orderId, restaurantId, and menuItems from the placed event
- Exhaustive `switch` with `never` check ensures all event types are handled
