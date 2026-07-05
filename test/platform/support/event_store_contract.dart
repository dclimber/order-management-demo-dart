import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/platform/event_store/event_store.dart';
import 'package:test/test.dart';

typedef EventStoreFactory = EventStore Function();
typedef EventStoreDisposer = void Function(EventStore store);

void runEventStoreContractTests(
  EventStoreFactory createStore, {
  EventStoreDisposer? disposeStore,
}) {
  late EventStore store;

  setUp(() {
    store = createStore();
  });

  tearDown(() {
    disposeStore?.call(store);
  });

  test('append stores events retrievable by tag query', () async {
    final created = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Italian Bistro'),
      menu: eventStoreTestMenu,
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
      menu: eventStoreTestMenu,
    );
    final second = RestaurantMenuChangedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      menu: eventStoreMexicanMenu,
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

  test('streamFor filters by event type', () async {
    await store
        .append(
          Stream.fromIterable([
            RestaurantCreatedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              name: RestaurantName('Italian Bistro'),
              menu: eventStoreTestMenu,
            ),
            RestaurantMenuChangedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              menu: eventStoreMexicanMenu,
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
      menuItems: eventStorePizzaItems,
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
      menu: eventStoreTestMenu,
    );
    final second = RestaurantMenuChangedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      menu: eventStoreMexicanMenu,
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
                menu: eventStoreTestMenu,
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
              menu: eventStoreTestMenu,
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

final eventStoreTestMenu = RestaurantMenu(
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

final eventStoreMexicanMenu = RestaurantMenu(
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

final eventStorePizzaItems = [
  MenuItem(
    menuItemId: MenuItemId('item-1'),
    name: MenuItemName('Pizza'),
    price: MenuItemPrice('10.00'),
  ),
];
