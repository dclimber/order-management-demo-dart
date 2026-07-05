import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../shell/components/api_client.dart';
import '../../../shell/components/form_common.dart';
import '../../../platform/id.dart';

@client
class CreateRestaurantForm extends StatefulComponent {
  const CreateRestaurantForm({super.key});

  @override
  State<CreateRestaurantForm> createState() => _CreateRestaurantFormState();
}

class _CreateRestaurantFormState extends State<CreateRestaurantForm> {
  var _restaurantId = '';
  var _name = '';
  var _cuisine = 'GENERAL';
  var _menuItems = [newMenuItemRow()];
  var _loading = false;
  String? _success;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _success = null;
      _error = null;
    });

    final response = await apiRequest(
      path: '/api/restaurant',
      method: 'POST',
      body: {
        'restaurantId': _restaurantId,
        'name': _name,
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
        notifyRestaurantCreated();
        setState(() {
          _loading = false;
          _success = 'Restaurant created successfully';
          _restaurantId = '';
          _name = '';
          _cuisine = 'GENERAL';
          _menuItems = [newMenuItemRow()];
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
        h2(classes: 'section-title', [.text('Create Restaurant')]),
        statusMessage(success: _success, error: _error),
        div(classes: 'form-grid', [
          div(classes: 'form-field', [
            label(attributes: {'for': 'create-name'}, [.text('Restaurant Name')]),
            input<String>(
              id: 'create-name',
              type: .text,
              value: _name,
              onInput: (value) => setState(() => _name = value),
              attributes: {'required': 'true'},
            ),
          ]),
          div(classes: 'form-field', [
            label(attributes: {'for': 'create-id'}, [.text('Restaurant ID')]),
            input<String>(
              id: 'create-id',
              type: .text,
              value: _restaurantId,
              onInput: (value) => setState(() => _restaurantId = value),
              attributes: {'required': 'true'},
            ),
          ]),
        ]),
        div(classes: 'form-field', [
          label(attributes: {'for': 'create-cuisine'}, [.text('Cuisine')]),
          select(
            id: 'create-cuisine',
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
          idPrefix: 'create',
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
          [.text(_loading ? 'Creating…' : 'Create Restaurant')],
        ),
      ],
    );
  }
}
