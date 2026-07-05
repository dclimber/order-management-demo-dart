import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/platform/event_store/event_store.dart';
import 'package:order_management_demo/platform/event_store/event_tags.dart';
import 'package:order_management_demo/platform/event_store/sqlite_event_store.dart';
import 'package:test/test.dart';

import '../support/event_store_contract.dart';
import 'test_setup.dart';

void main() {
  setUpAll(setUpPlatformEventStore);

  late SqliteEventStore store;

  runEventStoreContractTests(
    SqliteEventStore.memory,
    disposeStore: (eventStore) => (eventStore as SqliteEventStore).close(),
  );

  setUp(() {
    store = SqliteEventStore.memory();
  });

  tearDown(() {
    store.close();
  });

  test('lastEventVersion increments on append', () async {
    final event = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Italian Bistro'),
      menu: eventStoreTestMenu,
    );

    await store.append(Stream.value(event)).toList();

    final version = await store.lastEventVersion(
      eventType: 'RestaurantCreatedEvent',
      tag: 'restaurantId',
      value: 'restaurant-1',
    );

    expect(version, 1);
  });

  test('append rejects stale optimistic lock version', () async {
    final pointerKey = indexKey('RestaurantCreatedEvent', ['restaurantId:restaurant-1']);
    final first = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Italian Bistro'),
      menu: eventStoreTestMenu,
    );
    final conflicting = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Duplicate Bistro'),
      menu: eventStoreTestMenu,
    );

    await store.append(Stream.value(first)).toList();

    await expectLater(
      () => store
          .append(
            Stream.value(conflicting),
            expectedVersions: {pointerKey: null},
          )
          .toList(),
      throwsA(isA<OptimisticLockException>()),
    );
  });

  test('append succeeds when expected version matches', () async {
    final pointerKey = indexKey('RestaurantMenuChangedEvent', ['restaurantId:restaurant-1']);
    final created = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Italian Bistro'),
      menu: eventStoreTestMenu,
    );
    final menuChanged = RestaurantMenuChangedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      menu: eventStoreMexicanMenu,
    );

    await store.append(Stream.value(created)).toList();

    await store
        .append(
          Stream.value(menuChanged),
          expectedVersions: {pointerKey: null},
        )
        .toList();

    final loaded = await store
        .streamFor(
          tag: 'restaurantId',
          value: 'restaurant-1',
          eventTypes: [RestaurantMenuChangedEvent],
        )
        .toList();

    expect(loaded, [menuChanged]);
    expect(
      await store.lastEventVersion(
        eventType: 'RestaurantMenuChangedEvent',
        tag: 'restaurantId',
        value: 'restaurant-1',
      ),
      1,
    );
  });
}
