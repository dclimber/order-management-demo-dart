import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../dto.dart';
import '../state.dart';

Component restaurantLookupForm({String? restaurantId}) {
  return form(
    classes: 'lookup-form',
    attributes: {'method': 'get', 'action': '/restaurant'},
    [
      label(attributes: {'for': 'restaurant-id'}, [.text('Restaurant ID')]),
      input(
        id: 'restaurant-id',
        name: 'restaurantId',
        type: .text,
        attributes: restaurantId == null ? null : {'value': restaurantId},
      ),
      button(type: .submit, [.text('View Restaurant')]),
    ],
  );
}

Component restaurantViewCard(RestaurantViewState state) {
  return div(classes: 'data-card', [
    dl(classes: 'data-list', [
      div([
        dt([.text('Restaurant ID')]),
        dd([.text(state.restaurantId.value)]),
      ]),
      div([
        dt([.text('Name')]),
        dd([.text(state.name.value)]),
      ]),
      div([
        dt([.text('Cuisine')]),
        dd([.text(cuisineLabel(state.menu.cuisine))]),
      ]),
      div([
        dt([.text('Menu Items')]),
        dd([
          ul(classes: 'item-list', [
            for (final item in state.menu.menuItems) li([.text('${item.name.value} — ${item.price.value}')]),
          ]),
        ]),
      ]),
    ]),
  ]);
}

Component restaurantIndexList(List<RestaurantViewState> restaurants) {
  if (restaurants.isEmpty) {
    return p(classes: 'text-muted', [.text('No restaurants have been created yet.')]);
  }

  return div(classes: 'index-list', [
    h2(classes: 'section-title', [.text('Known Restaurants')]),
    ul([
      for (final restaurant in restaurants)
        li([
          a(
            href: '/restaurant?restaurantId=${restaurant.restaurantId.value}',
            [.text('${restaurant.name.value} (${restaurant.restaurantId.value})')],
          ),
        ]),
    ]),
  ]);
}
