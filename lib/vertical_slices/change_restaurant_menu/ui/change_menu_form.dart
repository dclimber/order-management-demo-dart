import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../../shell/components/api_client.dart';
import '../../../shell/components/form_common.dart';
import '../../../platform/id.dart';

@client
class ChangeMenuForm extends StatefulComponent {
  const ChangeMenuForm({this.initialRestaurants = const [], super.key});

  final List<Map<String, String>> initialRestaurants;

  @override
  State<ChangeMenuForm> createState() => _ChangeMenuFormState();
}

class _ChangeMenuFormState extends State<ChangeMenuForm> {
  late List<RestaurantSummary> _restaurants = parseRestaurantSummaries(component.initialRestaurants);
  var _restaurantsLoading = false;
  var _restaurantId = '';
  var _cuisine = 'GENERAL';
  var _menuItems = [newMenuItemRow()];
  var _loading = false;
  String? _success;
  String? _error;
  web.BroadcastChannel? _restaurantChannel;
  web.EventListener? _restaurantListener;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      if (_restaurants.isEmpty) {
        _fetchRestaurants();
      }
      _restaurantChannel = web.BroadcastChannel('restaurant-created');
      _restaurantListener = ((web.Event event) {
        _fetchRestaurants();
      }).toJS;
      _restaurantChannel!.addEventListener('message', _restaurantListener);
    }
  }

  @override
  void dispose() {
    if (_restaurantChannel != null && _restaurantListener != null) {
      _restaurantChannel!.removeEventListener('message', _restaurantListener);
    }
    super.dispose();
  }

  Future<void> _fetchRestaurants() async {
    setState(() => _restaurantsLoading = true);
    final response = await apiRequest(path: '/api/restaurant');
    if (response case ApiOk(:final data) when data is List) {
      setState(() {
        _restaurants = summariesFromRestaurantViews(data);
        _restaurantsLoading = false;
      });
      return;
    }
    setState(() => _restaurantsLoading = false);
  }

  Future<void> _onRestaurantChange(String restaurantId) async {
    setState(() {
      _restaurantId = restaurantId;
      _success = null;
      _error = null;
    });

    if (restaurantId.isEmpty) {
      setState(() {
        _cuisine = 'GENERAL';
        _menuItems = [newMenuItemRow()];
      });
      return;
    }

    setState(() => _loading = true);
    final response = await apiRequest(path: '/api/restaurant?restaurantId=$restaurantId');
    switch (response) {
      case ApiOk(:final data) when data is Map:
        final menu = data['menu'];
        if (menu is Map) {
          final items = menu['menuItems'];
          setState(() {
            _cuisine = menu['cuisine']?.toString().toUpperCase() ?? 'GENERAL';
            _menuItems = items is List && items.isNotEmpty
                ? [
                    for (final item in items)
                      if (item is Map)
                        (
                          menuItemId: item['menuItemId']?.toString() ?? generateId(),
                          name: item['name']?.toString() ?? '',
                          price: item['price']?.toString() ?? '',
                        ),
                  ]
                : [newMenuItemRow()];
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
        }
      case ApiFail(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
      default:
        setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _success = null;
      _error = null;
    });

    final response = await apiRequest(
      path: '/api/restaurant/menu',
      method: 'PUT',
      body: {
        'restaurantId': _restaurantId,
        'menu': {
          'menuId': generateId(),
          'cuisine': _cuisine,
          'menuItems': [
            for (final item in _menuItems)
              {
                'menuItemId': item.menuItemId,
                'name': item.name,
                'price': item.price,
              },
          ],
        },
      },
    );

    switch (response) {
      case ApiOk():
        setState(() {
          _loading = false;
          _success = 'Menu updated successfully';
        });
      case ApiFail(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
    }
  }

  void _updateMenuItem(int index, String field, String value) {
    setState(() {
      _menuItems = [
        for (var i = 0; i < _menuItems.length; i++)
          if (i == index)
            (
              menuItemId: _menuItems[i].menuItemId,
              name: field == 'name' ? value : _menuItems[i].name,
              price: field == 'price' ? value : _menuItems[i].price,
            )
          else
            _menuItems[i],
      ];
    });
  }

  @override
  Component build(BuildContext context) {
    return form(
      classes: 'client-form',
      events: {
        'submit': (event) {
          event.preventDefault();
          _submit();
        },
      },
      [
        h2(classes: 'section-title', [.text('Change Restaurant Menu')]),
        statusMessage(success: _success, error: _error),
        div(classes: 'form-field', [
          label(attributes: {'for': 'change-id'}, [.text('Restaurant')]),
          select(
            id: 'change-id',
            value: _restaurantId,
            onChange: (values) => _onRestaurantChange(values.first),
            attributes: {'required': 'true'},
            [
              option(
                value: '',
                [.text(_restaurantsLoading ? 'Loading restaurants…' : 'Select a restaurant')],
              ),
              for (final restaurant in _restaurants)
                option(
                  value: restaurant.restaurantId,
                  [.text('${restaurant.name} (${restaurant.restaurantId})')],
                ),
            ],
          ),
        ]),
        div(classes: 'form-field', [
          label(attributes: {'for': 'change-cuisine'}, [.text('Cuisine')]),
          select(
            id: 'change-cuisine',
            value: _cuisine,
            onChange: (values) => setState(() => _cuisine = values.first),
            [
              for (final cuisine in cuisineOptions) option(value: cuisine, [.text(cuisine)]),
            ],
          ),
        ]),
        menuItemFields(
          legendText: 'Menu Items',
          items: _menuItems,
          idPrefix: 'change',
          removeEnabled: _menuItems.length > 1,
          onUpdate: _updateMenuItem,
          onRemove: (index) => setState(() {
            _menuItems = [..._menuItems]..removeAt(index);
          }),
          onAdd: () => setState(() => _menuItems = [..._menuItems, newMenuItemRow()]),
        ),
        button(
          type: .submit,
          classes: 'btn-primary',
          attributes: _loading ? {'disabled': 'true'} : null,
          [.text(_loading ? 'Updating…' : 'Update Menu')],
        ),
      ],
    );
  }
}
