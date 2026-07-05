# Jaspr Integration for Event-Sourced Apps

This project runs Jaspr in **server mode** (`jaspr: mode: server` in
`pubspec.yaml`). Follow the layering rules so domain logic stays pure and
client/server boundaries stay clean.

## Related Skills

- [jaspr-fundamentals](../../jaspr-fundamentals/SKILL.md) — components, HTML, events
- [jaspr-pre-rendering-and-hydration](../../jaspr-pre-rendering-and-hydration/SKILL.md) — `@client`, async SSR, hydration
- [jaspr-styling](../../jaspr-styling/SKILL.md) — dashboard layout and forms

## Layer Responsibilities

| Layer | Runs on | May import | Must NOT import |
| ----- | ------- | ---------- | --------------- |
| `lib/api.dart` | everywhere | `package:fmodel` | `dart:io`, `package:web` |
| `lib/vertical_slices/<slice>/` | server | `api.dart`, `platform/`, `fmodel` | other slices |
| `lib/platform/` | server | `api.dart`, `fmodel` | slice-specific logic |
| `lib/shell/pages/` (no `@client`) | server SSR | composition, slice `ui/` exports | repositories with `dart:io` |
| slice `ui/` + `lib/shell/components/` (`@client`) | server + client | `package:jaspr` | repositories directly |

## Pattern 1: Server Handler (Testable, No Jaspr)

Extract command/query logic into plain Dart functions in each slice's
`handler.dart`. Test these without spinning up Jaspr — mirrors the Deno demo's
extracted handlers.

```dart
// lib/vertical_slices/create_restaurant/handler.dart
import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/aggregate.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';

sealed class HandlerResult<T> {
  const HandlerResult();
}

final class HandlerSuccess<T> extends HandlerResult<T> {
  const HandlerSuccess(this.value);
  final T value;
}

final class HandlerError extends HandlerResult<Never> {
  const HandlerError(this.statusCode, this.message);
  final int statusCode;
  final String message;
}

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

Unit-test handlers in `test/server/` with in-memory repositories.

## Pattern 2: SSR Query Page

Use `AsyncStatelessComponent` (server-only import) to load read-model state
before rendering HTML. Pass serializable data to `@client` children.

```dart
// lib/pages/kitchen.dart
import 'package:jaspr/server.dart';
import 'package:jaspr/dom.dart';

import '../application/app_services.dart';
import '../components/kitchen_dashboard.dart';

class Kitchen extends AsyncStatelessComponent {
  const Kitchen({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final orders = await appServices.kitchenOrders();

    return section(classes: 'kitchen', [
      h1([.text('Kitchen')]),
      KitchenDashboard(orders: orders),
    ]);
  }
}
```

`appServices` is a server-side composition root wiring aggregates, ephemeral
views, and the event store. Keep it out of `@client` components.

## Pattern 3: @client Command Form

Interactive forms that mutate state must be `@client`. They call server API
endpoints via `fetch` — never import repositories directly.

```dart
// lib/components/create_restaurant_form.dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:universal_web/web.dart' as web;

@client
class CreateRestaurantForm extends StatefulComponent {
  const CreateRestaurantForm({super.key});

  @override
  State<CreateRestaurantForm> createState() => _CreateRestaurantFormState();
}

class _CreateRestaurantFormState extends State<CreateRestaurantForm> {
  String? _error;

  Future<void> _submit(web.Event event) async {
    event.preventDefault();
    if (!kIsWeb) return;

    final response = await web.window.fetch(
      '/api/restaurant'.toJS,
      web.RequestInit(
        method: 'POST'.toJS,
        headers: {'Content-Type': 'application/json'}.jsify()! as web.HeadersInit,
        body: _buildJsonBody().toJS,
      ),
    );

    if (response.ok) {
      web.window.location.href = '/restaurant';
    } else {
      setState(() => _error = 'Failed to create restaurant');
    }
  }

  @override
  Component build(BuildContext context) {
    return form(events: {'submit': _submit}, [
      // input fields — see jaspr-fundamentals references/html/input.md
      if (_error != null) p(classes: 'error', [.text(_error!)]),
      button(type: .submit, [.text('Create')]),
    ]);
  }
}
```

### @client Parameter Rules

When passing server-fetched data into `@client` components:

- Parameters must be initializing fields (`required this.orders`)
- Must be serializable: primitives, `List`, `Map`, or types with `@encoder` /
  `@decoder`
- Do not pass functions, deciders, or repositories

## Pattern 4: API Route Wiring

Register API routes in the Jaspr server configuration. Handler functions stay
in `lib/server/` and receive a shared `AppServices` instance:

```dart
// lib/server/api.dart — called from main.server.dart or server bootstrap
import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;

shelf.Handler restaurantApiHandler(AppServices services) {
  return (shelf.Request request) async {
    if (request.method == 'POST') {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final command = parseCreateRestaurantCommand(body);
      final result = await handleCreateRestaurant(
        command: command,
        aggregate: services.createRestaurantAggregate,
      );
      return switch (result) {
        HandlerSuccess(:final value) => shelf.Response.ok(
          jsonEncode(value.map((e) => eventToJson(e)).toList()),
          headers: {'Content-Type': 'application/json'},
        ),
        HandlerError(:final statusCode, :final message) => shelf.Response(
          statusCode,
          body: jsonEncode({'error': message}),
          headers: {'Content-Type': 'application/json'},
        ),
      };
    }
    return shelf.Response.notFound('Not found');
  };
}
```

Map domain errors to HTTP status codes in handlers (400 validation, 404 not
found, 409 conflict).

## Pattern 5: App Composition Root

Wire all aggregates and views once in `lib/application/app_services.dart`:

```dart
final class AppServices {
  AppServices({required this.eventStore});

  final EventStore eventStore;

  late final createRestaurantAggregate = createRestaurantAggregate(
    repository: CreateRestaurantEventRepository(eventStore),
  );

  Future<List<OrderViewState>> kitchenOrders() async {
    // query via ephemeral view
  }
}
```

Inject `AppServices` into server handlers and `AsyncStatelessComponent` pages.

## UI Checklist per Feature

- [ ] Server handler in `lib/server/` with handler tests
- [ ] API route registered for mutations
- [ ] SSR page (`AsyncStatelessComponent`) for read-heavy views
- [ ] `@client` component for interactive forms (one `@client` per subtree)
- [ ] Route added in `lib/app.dart`
- [ ] Styles via `@css` per [jaspr-styling](../../jaspr-styling/SKILL.md)
- [ ] HTML components per `jaspr-fundamentals/references/html/`

## Deno Demo Feature Map

Port these features from the TypeScript reference:

| Feature | Deno route | Jaspr equivalent |
| ------- | ---------- | ---------------- |
| Create restaurant | `POST /api/restaurant` | server handler + `@client` form |
| Change menu | `POST /api/restaurant/menu` | server handler + form |
| Place order | `POST /api/order` | server handler + form |
| Mark prepared | `POST /api/kitchen` | server handler + dashboard |
| Order status | `GET /api/order` | SSR page or client fetch |
| Restaurant view | page + query | `AsyncStatelessComponent` |