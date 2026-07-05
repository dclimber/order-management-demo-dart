import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../platform/id.dart';

const cuisineOptions = [
  'GENERAL',
  'SERBIAN',
  'ITALIAN',
  'MEXICAN',
  'CHINESE',
  'INDIAN',
  'FRENCH',
];

typedef MenuItemFormRow = ({String menuItemId, String name, String price});

MenuItemFormRow newMenuItemRow() => (
  menuItemId: generateId(),
  name: '',
  price: '',
);

typedef RestaurantSummary = ({String restaurantId, String name});

List<RestaurantSummary> parseRestaurantSummaries(List<Map<String, String>> raw) {
  return [
    for (final entry in raw)
      if (entry['restaurantId'] != null && entry['name'] != null)
        (restaurantId: entry['restaurantId']!, name: entry['name']!),
  ];
}

List<RestaurantSummary> summariesFromRestaurantViews(List<dynamic> views) {
  return [
    for (final view in views)
      if (view is Map)
        (
          restaurantId: view['restaurantId']?.toString() ?? '',
          name: view['name']?.toString() ?? '',
        ),
  ].where((r) => r.restaurantId.isNotEmpty).toList();
}

Component statusMessage({String? success, String? error}) {
  return div([
    if (success != null) p(classes: 'success-message', attributes: {'role': 'status'}, [.text(success)]),
    if (error != null) p(classes: 'error-message', attributes: {'role': 'alert'}, [.text(error)]),
  ]);
}

Component menuItemFields({
  required String legendText,
  required List<MenuItemFormRow> items,
  required void Function(int index, String field, String value) onUpdate,
  required void Function(int index) onRemove,
  required VoidCallback onAdd,
  required bool removeEnabled,
  String idPrefix = 'item',
}) {
  return fieldset(classes: 'menu-items-fieldset', [
    legend(classes: 'form-legend', [.text(legendText)]),
    for (var i = 0; i < items.length; i++)
      div(classes: 'menu-item-row', [
        div(classes: 'form-field grow', [
          label(attributes: {'for': '$idPrefix-name-$i'}, [.text('Name')]),
          input<String>(
            id: '$idPrefix-name-$i',
            type: .text,
            value: items[i].name,
            onInput: (value) => onUpdate(i, 'name', value),
            attributes: {'required': 'true'},
          ),
        ]),
        div(classes: 'form-field price-field', [
          label(attributes: {'for': '$idPrefix-price-$i'}, [.text('Price')]),
          input<String>(
            id: '$idPrefix-price-$i',
            type: .text,
            value: items[i].price,
            onInput: (value) => onUpdate(i, 'price', value),
            attributes: {'required': 'true'},
          ),
        ]),
        button(
          type: .button,
          classes: 'btn-danger',
          onClick: removeEnabled ? () => onRemove(i) : null,
          attributes: removeEnabled ? null : {'disabled': 'true'},
          [.text('Remove')],
        ),
      ]),
    button(type: .button, classes: 'btn-ghost', onClick: onAdd, [.text('Add Menu Item')]),
  ]);
}
