import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:test/test.dart';

void main() {
  late InMemoryEventStore store;

  setUp(() {
    store = InMemoryEventStore();
  });

  test('append stores events retrievable by tag query', () async {
    final created = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Italian Bistro'),
      menu: _testMenu,
    );

    await store.append(Stream.value(created)).toList();

    final loaded = await store
        .streamFor(
          tag: 'restaurantId',
          value: 'restaurant-1',
          eventTypes: [RestaurantCreatedEvent],
        )
        .toList();

    expect(loaded, [created]);
  });

  test('streamFor returns events in chronological order', () async {
    final first = RestaurantMenuChangedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      menu: _testMenu,
    );
    final second = RestaurantMenuChangedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      menu: _mexicanMenu,
    );

    await store.append(Stream.fromIterable([first, second])).toList();

    final loaded = await store
        .streamFor(
          tag: 'restaurantId',
          value: 'restaurant-1',
          eventTypes: [RestaurantMenuChangedEvent],
        )
        .toList();

    expect(loaded, [first, second]);
  });

  test('streamByEventType returns events of one type in order', () async {
    final created = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Italian Bistro'),
      menu: _testMenu,
    );
    final placed = RestaurantOrderPlacedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      orderId: OrderId('order-1'),
      menuItems: _testMenu.menuItems,
    );

    await store.append(Stream.fromIterable([created, placed])).toList();

    final loaded = await store.streamByEventType('RestaurantCreatedEvent').toList();

    expect(loaded, [created]);
  });

  test('streamFor filters by event type', () async {
    await store
        .append(
          Stream.fromIterable([
            RestaurantCreatedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              name: RestaurantName('Italian Bistro'),
              menu: _testMenu,
            ),
            RestaurantMenuChangedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              menu: _mexicanMenu,
            ),
          ]),
        )
        .toList();

    final createdOnly = await store
        .streamFor(
          tag: 'restaurantId',
          value: 'restaurant-1',
          eventTypes: [RestaurantCreatedEvent],
        )
        .toList();

    expect(createdOnly, hasLength(1));
    expect(createdOnly.single, isA<RestaurantCreatedEvent>());
  });

  test('multi-tag event indexed by each tag subset', () async {
    final placed = RestaurantOrderPlacedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      orderId: OrderId('order-1'),
      menuItems: _pizzaItems,
    );

    await store.append(Stream.value(placed)).toList();

    final byRestaurant = await store
        .streamFor(
          tag: 'restaurantId',
          value: 'restaurant-1',
          eventTypes: [RestaurantOrderPlacedEvent],
        )
        .toList();
    final byOrder = await store
        .streamFor(
          tag: 'orderId',
          value: 'order-1',
          eventTypes: [RestaurantOrderPlacedEvent],
        )
        .toList();

    expect(byRestaurant, [placed]);
    expect(byOrder, [placed]);
  });

  test('lastEventId returns latest appended event id', () async {
    final first = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Italian Bistro'),
      menu: _testMenu,
    );
    final second = RestaurantMenuChangedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      menu: _mexicanMenu,
    );

    await store.append(Stream.value(first)).toList();
    final firstId = await store.lastEventId(
      eventType: 'RestaurantCreatedEvent',
      tag: 'restaurantId',
      value: 'restaurant-1',
    );

    await store.append(Stream.value(second)).toList();
    final menuChangedId = await store.lastEventId(
      eventType: 'RestaurantMenuChangedEvent',
      tag: 'restaurantId',
      value: 'restaurant-1',
    );

    expect(firstId, isNotNull);
    expect(menuChangedId, isNotNull);
    expect(menuChangedId, isNot(equals(firstId)));
  });

  test('withTransaction exposes the same store to the action', () async {
    await store.withTransaction((tx) async {
      await tx
          .append(
            Stream.value(
              RestaurantCreatedEvent(
                restaurantId: RestaurantId('restaurant-1'),
                name: RestaurantName('Italian Bistro'),
                menu: _testMenu,
              ),
            ),
          )
          .toList();
      return null;
    });

    final loaded = await store
        .streamFor(
          tag: 'restaurantId',
          value: 'restaurant-1',
          eventTypes: [RestaurantCreatedEvent],
        )
        .toList();

    expect(loaded, hasLength(1));
  });

  test('clear removes all events', () async {
    await store
        .append(
          Stream.value(
            RestaurantCreatedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              name: RestaurantName('Italian Bistro'),
              menu: _testMenu,
            ),
          ),
        )
        .toList();

    await store.clear();

    final loaded = await store
        .streamFor(
          tag: 'restaurantId',
          value: 'restaurant-1',
          eventTypes: [RestaurantCreatedEvent],
        )
        .toList();

    expect(loaded, isEmpty);
  });
}

final _testMenu = RestaurantMenu(
  menuItems: [
    MenuItem(
      menuItemId: MenuItemId('item-1'),
      name: MenuItemName('Pizza'),
      price: MenuItemPrice('10.00'),
    ),
  ],
  menuId: RestaurantMenuId('menu-1'),
  cuisine: RestaurantMenuCuisine.italian,
);

final _mexicanMenu = RestaurantMenu(
  menuItems: [
    MenuItem(
      menuItemId: MenuItemId('item-3'),
      name: MenuItemName('Tacos'),
      price: MenuItemPrice('8.00'),
    ),
  ],
  menuId: RestaurantMenuId('menu-2'),
  cuisine: RestaurantMenuCuisine.mexican,
);

final _pizzaItems = [
  MenuItem(
    menuItemId: MenuItemId('item-1'),
    name: MenuItemName('Pizza'),
    price: MenuItemPrice('10.00'),
  ),
];
