actor "admin" {
  description   = "Restaurant administrator and kitchen staff. Stated: Admin lane in README blueprint (f1.png)."
  auth_required = true
}

actor "customer" {
  description   = "Orders food and tracks order status. Stated: Customer lane in README blueprint (f1.png)."
  auth_required = true
}

bounded_context "restaurant_management" {
  description = "Restaurants, menus and orders. Consistency boundaries are per use case (DCB); aggregates name the event streams, see README."

  aggregate "restaurant" {
    description = "Restaurant tagged events (RestaurantEvent in lib/api.dart)."
  }

  aggregate "order" {
    description = "Order tagged events (OrderEvent in lib/api.dart)."
  }

  field_type "restaurant_id" {
    type         = "String"
    id_attribute = true
    example      = "restaurant-1"
  }

  field_type "order_id" {
    type         = "String"
    id_attribute = true
    example      = "order-1"
  }

  field_type "restaurant_name" {
    type    = "String"
    example = "Ce Vino"
  }

  field_type "menu_items" {
    cardinality = "List"
    type        = "Custom"

    subfield "menu_item_id" {
      type         = "String"
      id_attribute = true
    }

    subfield "name" {
      type = "String"
    }

    subfield "price" {
      type = "String"
    }
  }

  field_type "menu" {
    type = "Custom"

    subfield "menu_id" {
      type         = "String"
      id_attribute = true
    }

    subfield "cuisine" {
      type = "String"
    }

    subfield "menu_items" {
      cardinality = "List"
      type        = "Custom"

      subfield "menu_item_id" {
        type         = "String"
        id_attribute = true
      }

      subfield "name" {
        type = "String"
      }

      subfield "price" {
        type = "String"
      }
    }
  }

  field_type "order_status" {
    type    = "String"
    example = "created"
  }

  event "restaurant_created" {
    aggregate = aggregate.restaurant
    fields    = [field_type.restaurant_id, field_type.restaurant_name, field_type.menu]
  }

  event "restaurant_menu_changed" {
    aggregate = aggregate.restaurant
    fields    = [field_type.restaurant_id, field_type.menu]
  }

  event "order_placed" {
    title                  = "Order Placed"
    description            = "RestaurantOrderPlacedEvent in code."
    aggregate              = aggregate.order
    aggregate_dependencies = [aggregate.restaurant]
    fields                 = [field_type.restaurant_id, field_type.order_id, field_type.menu_items]
  }

  event "order_prepared" {
    aggregate = aggregate.order
    fields    = [field_type.order_id]
  }
}

state_change "create_restaurant" {
  screen "create_restaurant_form" {
    actor     = actor.admin
    prototype = { route = "/restaurant" }
    to        = [command.create_restaurant]
  }

  command "create_restaurant" {
    aggregate         = aggregate.restaurant_management.restaurant
    api_endpoint      = "POST /api/restaurant"
    creates_aggregate = true
    fields            = [field_type.restaurant_management.restaurant_id, field_type.restaurant_management.restaurant_name, field_type.restaurant_management.menu]
    to                = [event.restaurant_management.restaurant_created]
  }

  scenario "restaurant_created" {
    when {
      command = command.create_restaurant
    }

    then {
      event = event.restaurant_management.restaurant_created
    }
  }

  scenario "restaurant_already_exists" {
    given {
      event = event.restaurant_management.restaurant_created
    }

    when {
      command = command.create_restaurant
    }

    then {
      error = "Restaurant {restaurant_id} already exists"
    }
  }
}

state_view "restaurant_view" {
  readmodel "restaurant" {
    question = "What is the name and current menu of a restaurant (or of all restaurants)?"
    fields   = [field_type.restaurant_management.restaurant_id, field_type.restaurant_management.restaurant_name, field_type.restaurant_management.menu]
    from     = [event.restaurant_management.restaurant_created, event.restaurant_management.restaurant_menu_changed]
    to       = [screen.restaurant_menu, screen.restaurant_list]
  }

  screen "restaurant_menu" {
    description = "Admin sees the current menu before changing it (GET /api/restaurant)."
    actor       = actor.admin
    prototype   = { route = "/restaurant" }
  }

  screen "restaurant_list" {
    description = "Customer picks a restaurant and menu items before placing an order."
    actor       = actor.customer
    prototype   = { route = "/order" }
  }

  scenario "restaurant_created_shown" {
    given {
      event = event.restaurant_management.restaurant_created
    }

    then {
      readmodel = readmodel.restaurant
    }
  }

  scenario "menu_change_replaces_menu" {
    given {
      event = event.restaurant_management.restaurant_created
    }

    given {
      event = event.restaurant_management.restaurant_menu_changed
    }

    then {
      readmodel = readmodel.restaurant
    }

    comment {
      description = "Name is kept from Restaurant Created; menu is taken from the latest Restaurant Menu Changed."
    }
  }
}

state_change "change_restaurant_menu" {
  screen "change_menu_form" {
    actor     = actor.admin
    prototype = { route = "/restaurant" }
    to        = [command.change_restaurant_menu]
  }

  command "change_restaurant_menu" {
    aggregate    = aggregate.restaurant_management.restaurant
    api_endpoint = "PUT /api/restaurant/menu"
    fields       = [field_type.restaurant_management.restaurant_id, field_type.restaurant_management.menu]
    to           = [event.restaurant_management.restaurant_menu_changed]
  }

  scenario "menu_changed" {
    given {
      event = event.restaurant_management.restaurant_created
    }

    when {
      command = command.change_restaurant_menu
    }

    then {
      event = event.restaurant_management.restaurant_menu_changed
    }
  }

  scenario "restaurant_not_found" {
    when {
      command = command.change_restaurant_menu
    }

    then {
      error = "Restaurant {restaurant_id} does not exist"
    }
  }
}

state_change "place_order" {
  screen "place_order_form" {
    actor     = actor.customer
    prototype = { route = "/order" }
    to        = [command.place_order]
  }

  command "place_order" {
    aggregate              = aggregate.restaurant_management.order
    aggregate_dependencies = [aggregate.restaurant_management.restaurant]
    api_endpoint           = "POST /api/order"
    creates_aggregate      = true
    fields                 = [field_type.restaurant_management.restaurant_id, field_type.restaurant_management.order_id, field_type.restaurant_management.menu_items]
    to                     = [event.restaurant_management.order_placed]
  }

  scenario "order_placed" {
    given {
      event = event.restaurant_management.restaurant_created
    }

    when {
      command = command.place_order
    }

    then {
      event = event.restaurant_management.order_placed
    }
  }

  scenario "order_placed_from_changed_menu" {
    given {
      event = event.restaurant_management.restaurant_created
    }

    given {
      event = event.restaurant_management.restaurant_menu_changed
    }

    when {
      command = command.place_order
    }

    then {
      event = event.restaurant_management.order_placed
    }

    comment {
      description = "Availability is checked against the latest menu."
    }
  }

  scenario "restaurant_not_found" {
    when {
      command = command.place_order
    }

    then {
      error = "Restaurant {restaurant_id} does not exist"
    }
  }

  scenario "order_already_exists" {
    given {
      event = event.restaurant_management.restaurant_created
    }

    given {
      event = event.restaurant_management.order_placed
    }

    when {
      command = command.place_order
    }

    then {
      error = "Order {order_id} already exists"
    }
  }

  scenario "menu_items_not_available" {
    given {
      event = event.restaurant_management.restaurant_created
    }

    when {
      command = command.place_order
    }

    then {
      error = "Menu items not available: {menu_item_ids}"
    }

    comment {
      description = "Every ordered menu_item_id must be on the restaurant's current menu."
    }
  }
}

state_view "order_view" {
  readmodel "order" {
    question = "What was ordered and what is the status of an order (or of all orders with a given status)?"
    fields   = [field_type.restaurant_management.order_id, field_type.restaurant_management.restaurant_id, field_type.restaurant_management.menu_items, field_type.restaurant_management.order_status]
    from     = [event.restaurant_management.order_placed, event.restaurant_management.order_prepared]
    to       = [screen.order_status_tracker, screen.kitchen_dashboard]
  }

  screen "order_status_tracker" {
    description = "Customer tracks an order (GET /api/order)."
    actor       = actor.customer
    prototype   = { route = "/order" }
  }

  screen "kitchen_dashboard" {
    description = "Admin lists orders by status (GET /api/kitchen) and picks one to mark as prepared."
    actor       = actor.admin
    prototype   = { route = "/kitchen" }
  }

  scenario "order_created" {
    given {
      event = event.restaurant_management.order_placed
    }

    then {
      readmodel = readmodel.order
    }

    comment {
      description = "status = created."
    }
  }

  scenario "order_prepared" {
    given {
      event = event.restaurant_management.order_placed
    }

    given {
      event = event.restaurant_management.order_prepared
    }

    then {
      readmodel = readmodel.order
    }

    comment {
      description = "status = prepared."
    }
  }
}

state_change "mark_order_as_prepared" {
  screen "kitchen_order" {
    actor     = actor.admin
    prototype = { route = "/kitchen" }
    to        = [command.mark_order_as_prepared]
  }

  command "mark_order_as_prepared" {
    aggregate    = aggregate.restaurant_management.order
    api_endpoint = "POST /api/kitchen"
    fields       = [field_type.restaurant_management.order_id]
    to           = [event.restaurant_management.order_prepared]
  }

  scenario "order_prepared" {
    given {
      event = event.restaurant_management.order_placed
    }

    when {
      command = command.mark_order_as_prepared
    }

    then {
      event = event.restaurant_management.order_prepared
    }
  }

  scenario "order_not_found" {
    when {
      command = command.mark_order_as_prepared
    }

    then {
      error = "Order {order_id} does not exist"
    }
  }

  scenario "order_already_prepared" {
    given {
      event = event.restaurant_management.order_placed
    }

    given {
      event = event.restaurant_management.order_prepared
    }

    when {
      command = command.mark_order_as_prepared
    }

    then {
      error = "Order {order_id} is already prepared"
    }
  }
}
