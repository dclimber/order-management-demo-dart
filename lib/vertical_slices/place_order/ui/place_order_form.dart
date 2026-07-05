import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../../shell/components/api_client.dart';
import '../../../shell/components/form_common.dart';
import '../../../platform/id.dart';

@client
class PlaceOrderForm extends StatefulComponent {
  const PlaceOrderForm({this.initialRestaurants = const [], super.key});

  final List<Map<String, String>> initialRestaurants;

  @override
  State<PlaceOrderForm> createState() => _PlaceOrderFormState();
}

class _PlaceOrderFormState extends State<PlaceOrderForm> {
  late List<RestaurantSummary> _restaurants = parseRestaurantSummaries(component.initialRestaurants);
  var _restaurantsLoading = false;
  var _restaurantId = '';
  var _orderId = generateId();
  var _availableMenu = <MenuItemFormRow>[];
  final _selectedItems = <String>{};
  var _menuLoading = false;
  String? _menuError;
  var _loading = false;
  String? _success;
  String? _error;
  var _copied = false;
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

  Future<void> _copyOrderId() async {
    if (!kIsWeb) return;
    web.window.navigator.clipboard.writeText(_orderId);
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _onRestaurantChange(String restaurantId) async {
    setState(() {
      _restaurantId = restaurantId;
      _availableMenu = [];
      _selectedItems.clear();
      _menuError = null;
      _success = null;
      _error = null;
    });

    if (restaurantId.isEmpty) return;

    setState(() => _menuLoading = true);
    final response = await apiRequest(path: '/api/restaurant?restaurantId=$restaurantId');
    switch (response) {
      case ApiOk(:final data) when data is Map:
        final menu = data['menu'];
        final items = menu is Map ? menu['menuItems'] : null;
        setState(() {
          _availableMenu = items is List
              ? [
                  for (final item in items)
                    if (item is Map)
                      (
                        menuItemId: item['menuItemId']?.toString() ?? '',
                        name: item['name']?.toString() ?? '',
                        price: item['price']?.toString() ?? '',
                      ),
                ]
              : [];
          _menuLoading = false;
        });
      case ApiFail(:final message):
        setState(() {
          _menuLoading = false;
          _menuError = message;
        });
      default:
        setState(() => _menuLoading = false);
    }
  }

  void _toggleItem(String menuItemId) {
    setState(() {
      if (_selectedItems.contains(menuItemId)) {
        _selectedItems.remove(menuItemId);
      } else {
        _selectedItems.add(menuItemId);
      }
    });
  }

  Future<void> _submit() async {
    final chosen = _availableMenu.where((item) => _selectedItems.contains(item.menuItemId)).toList();
    if (chosen.isEmpty) {
      setState(() => _error = 'Select at least one menu item');
      return;
    }

    setState(() {
      _loading = true;
      _success = null;
      _error = null;
    });

    final response = await apiRequest(
      path: '/api/order',
      method: 'POST',
      body: {
        'restaurantId': _restaurantId,
        'orderId': _orderId,
        'menuItems': [
          for (final item in chosen)
            {
              'menuItemId': item.menuItemId,
              'name': item.name,
              'price': item.price,
            },
        ],
      },
    );

    switch (response) {
      case ApiOk():
        setState(() {
          _loading = false;
          _success = 'Order placed successfully';
          _restaurantId = '';
          _orderId = generateId();
          _availableMenu = [];
          _selectedItems.clear();
          _menuError = null;
        });
      case ApiFail(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
    }
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
        h2(classes: 'section-title', [.text('Place Order')]),
        statusMessage(success: _success, error: _error),
        div(classes: 'form-grid', [
          div(classes: 'form-field', [
            label(attributes: {'for': 'order-restaurant-id'}, [.text('Restaurant')]),
            select(
              id: 'order-restaurant-id',
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
            label(attributes: {'for': 'order-id'}, [.text('Order ID')]),
            div(classes: 'input-with-button', [
              input<String>(
                id: 'order-id',
                type: .text,
                value: _orderId,
                onInput: (value) => setState(() => _orderId = value),
                attributes: {'required': 'true'},
              ),
              button(
                type: .button,
                classes: 'btn-ghost',
                onClick: _copyOrderId,
                [.text(_copied ? '✓' : 'Copy')],
              ),
            ]),
          ]),
        ]),
        if (_menuLoading) p(classes: 'text-muted', [.text('Loading menu…')]),
        if (_menuError != null) p(classes: 'error-message', attributes: {'role': 'alert'}, [.text(_menuError!)]),
        if (_availableMenu.isNotEmpty)
          fieldset(classes: 'menu-items-fieldset', [
            legend(classes: 'form-legend', [.text('Select Menu Items')]),
            table(classes: 'menu-table', [
              thead([
                tr([
                  th([.text('')]),
                  th([.text('Name')]),
                  th([.text('Price')]),
                ]),
              ]),
              tbody([
                for (final item in _availableMenu)
                  tr(
                    events: {'click': (_) => _toggleItem(item.menuItemId)},
                    [
                      td([
                        input<bool>(
                          type: .checkbox,
                          checked: _selectedItems.contains(item.menuItemId),
                          onChange: (_) => _toggleItem(item.menuItemId),
                          attributes: {'aria-label': 'Select ${item.name}'},
                        ),
                      ]),
                      td([.text(item.name)]),
                      td([.text(item.price)]),
                    ],
                  ),
              ]),
            ]),
          ]),
        button(
          type: .submit,
          classes: 'btn-primary',
          attributes: (_loading || _selectedItems.isEmpty) ? {'disabled': 'true'} : null,
          [.text(_loading ? 'Placing…' : 'Place Order')],
        ),
      ],
    );
  }
}
