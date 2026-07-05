# Writing Given-When-Then Requirements for Deciders

This guide explains how to write `REQUIREMENTS-{Command}.md` documents that
serve as the single source of truth for a use case. These docs drive both the
decider implementation and the Given-When-Then test suite.

## Why Given-When-Then for Requirements?

In event-sourced systems, the Given-When-Then format maps directly to the
decider's computation model:

| GWT Clause | Decider Concept | Meaning                              |
| ---------- | --------------- | ------------------------------------ |
| **Given**  | Input events    | Past events that build current state |
| **When**   | Command         | The action being requested           |
| **Then**   | Output events   | Events produced (or error thrown)    |

Requirements written this way are _executable specifications_ — each scenario
translates 1:1 into a domain test:

```dart
await decider
    .givenEvents([...])   // Given
    .whenCommand(cmd)    // When
    .thenEvents([...]);  // Then
```

## File Naming Convention

```
REQUIREMENTS-{CommandName}.md
```

Examples:

- `REQUIREMENTS-CreateRestaurant.md`
- `REQUIREMENTS-PlaceOrder.md`
- `REQUIREMENTS-MarkOrderAsPrepared.md`

Place these in your project's `doc/` directory. Example templates live in this
skill's `references/` folder.

## Document Structure

Every requirements doc follows this template:

````markdown
# Requirements: {CommandName}

Command: `{CommandName}` Decider: `{commandName}Decider` Slice: {brief description}

## Description

{1-2 sentences explaining what this use case does and why it exists.}

## Input Events (Consistency Boundary)

| Event       | Tag Field  | Purpose                  |
| ----------- | ---------- | ------------------------ |
| `SomeEvent` | `entityId` | Why this event is loaded |

## Output Events

| Event           | Tag Fields |
| --------------- | ---------- |
| `ProducedEvent` | `entityId` |

## Scenarios

### Scenario N: {descriptive name}

\```gherkin
Given {precondition events or "no prior events"}
When {CommandName} is issued with {field} "{value}"
Then {expected outcome: event produced or error thrown}
\```

## Domain Errors

| Error       | Condition                       |
| ----------- | ------------------------------- |
| `SomeError` | When this invariant is violated |

## State Shape

\```dart
final class {UseCase}State {
  // fields needed for decide logic
}
\```
````

## Writing Scenarios

### Rule 1: One scenario per behavior

Each scenario tests exactly one path through `decide`:

- One happy path
- One scenario per domain error (guard clause)
- One scenario per interesting state transition

### Rule 2: Given = input events that build state

```gherkin
Given RestaurantCreatedEvent occurred
  with restaurantId "restaurant-1"
  and name "Italian Bistro"
  and menu containing [Pizza ($10.00)]
```

For initial state:

```gherkin
Given no prior events
```

### Rule 3: When = the command under test

```gherkin
When CreateRestaurantCommand is issued
  with restaurantId "restaurant-1"
  and name "Italian Bistro"
  and menu containing [Pizza ($10.00), Pasta ($12.00)]
```

### Rule 4: Then = output events or domain error

Success:

```gherkin
Then RestaurantCreatedEvent is produced
  with restaurantId "restaurant-1"
```

Error:

```gherkin
Then RestaurantAlreadyExistsError is thrown
```

### Rule 5: Scenarios map 1:1 to tests

```dart
// Scenario: "Successfully create a restaurant"
await createRestaurantDecider
    .givenEvents([])
    .whenCommand(command)
    .thenEvents([restaurantCreatedEvent]);

// Scenario: "Reject duplicate restaurant creation"
await expectLater(
  () => createRestaurantDecider
      .givenEvents([restaurantCreatedEvent])
      .whenCommand(command)
      .thenEvents([]),
  throwsA(isA<RestaurantAlreadyExistsError>()),
);
```

## Identifying Scenarios

Ask these questions:

1. **What must exist?** → error scenario when missing
2. **What must NOT exist?** → error scenario when duplicate
3. **What invariants must hold?** → one error per violated invariant
4. **What state transitions affect this?** → scenarios with prior changes
5. **What's the happy path?** → success with all preconditions met

## Cross-Boundary Use Cases

Document each entity boundary in the Input Events table:

```markdown
## Input Events (Consistency Boundary)

| Event                        | Tag Field      | Purpose                             |
| ---------------------------- | -------------- | ----------------------------------- |
| `RestaurantCreatedEvent`     | `restaurantId` | Verify restaurant exists + get menu |
| `RestaurantMenuChangedEvent` | `restaurantId` | Get latest menu                     |
| `RestaurantOrderPlacedEvent` | `orderId`      | Check if order already exists       |
```

The repository's `fetchEvents(command)` must load all listed event types.

## View Requirements — Given-Then

Views have no command. Use **Given-Then** format:

```gherkin
Given RestaurantCreatedEvent occurred with restaurantId "restaurant-1"
Then view state is restaurantId "restaurant-1" name "Italian Bistro"
```

Maps to:

```dart
restaurantView
    .givenEvents([restaurantCreatedEvent])
    .thenState(expectedViewState);
```

## Example Requirements Documents

### Slices (Deciders) — Given-When-Then

- [REQUIREMENTS-CreateRestaurant.md](REQUIREMENTS-CreateRestaurant.md)
- [REQUIREMENTS-ChangeRestaurantMenu.md](REQUIREMENTS-ChangeRestaurantMenu.md)
- [REQUIREMENTS-PlaceOrder.md](REQUIREMENTS-PlaceOrder.md)
- [REQUIREMENTS-MarkOrderAsPrepared.md](REQUIREMENTS-MarkOrderAsPrepared.md)

### Views — Given-Then

- [REQUIREMENTS-VIEW-RestaurantView.md](REQUIREMENTS-VIEW-RestaurantView.md)
- [REQUIREMENTS-VIEW-OrderView.md](REQUIREMENTS-VIEW-OrderView.md)