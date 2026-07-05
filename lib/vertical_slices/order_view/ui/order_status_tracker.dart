import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../shell/components/api_client.dart';

@client
class OrderStatusTracker extends StatefulComponent {
  const OrderStatusTracker({super.key});

  @override
  State<OrderStatusTracker> createState() => _OrderStatusTrackerState();
}

class _OrderStatusTrackerState extends State<OrderStatusTracker> {
  var _orderId = '';
  Map<String, dynamic>? _orderView;
  var _loading = false;
  String? _error;
  var _autoPoll = false;

  @override
  void dispose() {
    _autoPoll = false;
    super.dispose();
  }

  void _schedulePoll() {
    if (!kIsWeb || !_autoPoll || _orderView == null) return;
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted || !_autoPoll) return;
      _trackOrder(silent: true).then((_) => _schedulePoll());
    });
  }

  Future<void> _trackOrder({bool silent = false}) async {
    if (_orderId.trim().isEmpty) return;

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
        _orderView = null;
      });
    }

    final response = await apiRequest(
      path: '/api/order?orderId=${Uri.encodeComponent(_orderId.trim())}',
    );

    switch (response) {
      case ApiOk(:final data) when data is Map:
        setState(() {
          _orderView = Map<String, dynamic>.from(data);
          _loading = false;
          _error = null;
          _autoPoll = true;
        });
        _schedulePoll();
      case ApiFail(:final message):
        setState(() {
          _loading = false;
          _error = message;
          _orderView = null;
          _autoPoll = false;
        });
      default:
        setState(() {
          _loading = false;
          _error = 'Request failed';
          _autoPoll = false;
        });
    }
  }

  @override
  Component build(BuildContext context) {
    final status = _orderView?['status']?.toString() ?? '';
    final statusClass = status == 'PREPARED' ? 'status-badge prepared' : 'status-badge created';

    return div(classes: 'client-form', [
      h2(classes: 'section-title', [.text('Track Order')]),
      if (_error != null) p(classes: 'error-message', attributes: {'role': 'alert'}, [.text(_error!)]),
      div(classes: 'lookup-form', [
        div(classes: 'form-field grow', [
          label(attributes: {'for': 'track-order-id'}, [.text('Order ID')]),
          input<String>(
            id: 'track-order-id',
            type: .text,
            value: _orderId,
            onInput: (value) => setState(() {
              _orderId = value;
              _autoPoll = false;
            }),
          ),
        ]),
        button(
          type: .button,
          classes: 'btn-primary',
          onClick: _loading ? null : () => _trackOrder(),
          attributes: _loading ? {'disabled': 'true'} : null,
          [.text(_loading ? 'Loading…' : 'Track Order')],
        ),
      ]),
      if (_orderView != null)
        div(classes: 'data-card', [
          dl(classes: 'data-list', [
            div([
              dt([.text('Order ID')]),
              dd([.text(_orderView!['orderId']?.toString() ?? '')]),
            ]),
            div([
              dt([.text('Restaurant ID')]),
              dd([.text(_orderView!['restaurantId']?.toString() ?? '')]),
            ]),
            div([
              dt([.text('Status')]),
              dd([
                span(classes: statusClass, [.text(status)]),
              ]),
            ]),
            div([
              dt([.text('Menu Items')]),
              dd([
                ul(classes: 'item-list', [
                  for (final item in (_orderView!['menuItems'] as List? ?? []))
                    if (item is Map) li([.text('${item['name']} — ${item['price']}')]),
                ]),
              ]),
            ]),
          ]),
          if (_autoPoll) p(classes: 'text-muted', [.text('Auto-refreshing every 10 seconds.')]),
        ]),
    ]);
  }
}
