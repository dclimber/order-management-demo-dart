import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../shell/components/api_client.dart';

@client
class KitchenDashboard extends StatefulComponent {
  const KitchenDashboard({
    this.initialCreatedOrders = const [],
    this.initialPreparedOrders = const [],
    super.key,
  });

  final List<Map<String, dynamic>> initialCreatedOrders;
  final List<Map<String, dynamic>> initialPreparedOrders;

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> {
  late List<Map<String, dynamic>> _createdOrders = [...component.initialCreatedOrders];
  late List<Map<String, dynamic>> _preparedOrders = [...component.initialPreparedOrders];
  var _autoRefresh = true;
  var _loading = false;
  String? _error;
  String? _markingOrderId;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _fetchOrders();
      _startPolling();
    }
  }

  void _startPolling() {
    if (!kIsWeb || !_autoRefresh) return;
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted || !_autoRefresh) return;
      _fetchOrders(silent: true).then((_) => _startPolling());
    });
  }

  Future<void> _fetchOrders({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }

    final createdResponse = await apiRequest(path: '/api/kitchen?status=CREATED');
    final preparedResponse = await apiRequest(path: '/api/kitchen?status=PREPARED');

    if (createdResponse is ApiFail || preparedResponse is ApiFail) {
      setState(() {
        _loading = false;
        _error = 'Failed to fetch orders';
      });
      return;
    }

    setState(() {
      _createdOrders = _parseOrders((createdResponse as ApiOk).data);
      _preparedOrders = _parseOrders((preparedResponse as ApiOk).data);
      _loading = false;
      _error = null;
    });
  }

  List<Map<String, dynamic>> _parseOrders(dynamic data) {
    if (data is! List) return [];
    return [
      for (final entry in data)
        if (entry is Map<String, dynamic>) entry else if (entry is Map) Map<String, dynamic>.from(entry),
    ];
  }

  Future<void> _markAsPrepared(String orderId) async {
    setState(() {
      _markingOrderId = orderId;
      _error = null;
    });

    final response = await apiRequest(
      path: '/api/kitchen',
      method: 'POST',
      body: {'orderId': orderId},
    );

    switch (response) {
      case ApiOk():
        final order = _createdOrders.firstWhere(
          (entry) => entry['orderId'] == orderId,
          orElse: () => <String, dynamic>{},
        );
        setState(() {
          _createdOrders = _createdOrders.where((entry) => entry['orderId'] != orderId).toList();
          if (order.isNotEmpty) {
            _preparedOrders = [
              ..._preparedOrders,
              {...order, 'status': 'PREPARED'},
            ];
          }
          _markingOrderId = null;
        });
      case ApiFail(:final message):
        setState(() {
          _markingOrderId = null;
          _error = message;
        });
    }
  }

  Component _orderCard(Map<String, dynamic> order, {required bool showMarkButton}) {
    final menuItems = order['menuItems'];
    return div(classes: 'data-card kitchen-order-card', [
      dl(classes: 'data-list', [
        div([
          dt([.text('Order ID')]),
          dd([.text(order['orderId']?.toString() ?? '')]),
        ]),
        div([
          dt([.text('Restaurant ID')]),
          dd([.text(order['restaurantId']?.toString() ?? '')]),
        ]),
        div([
          dt([.text('Menu Items')]),
          dd([
            if (menuItems is List)
              ul(classes: 'item-list', [
                for (final item in menuItems)
                  if (item is Map) li([.text('${item['name']} — ${item['price']}')]),
              ]),
          ]),
        ]),
      ]),
      if (showMarkButton)
        button(
          type: .button,
          classes: 'btn-primary',
          onClick: _markingOrderId == order['orderId'] ? null : () => _markAsPrepared(order['orderId'].toString()),
          attributes: _markingOrderId == order['orderId'] ? {'disabled': 'true'} : null,
          [.text(_markingOrderId == order['orderId'] ? 'Marking…' : 'Mark as Prepared')],
        ),
    ]);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'kitchen-dashboard', [
      div(classes: 'kitchen-controls', [
        label(attributes: {'for': 'auto-refresh-toggle'}, [.text('Auto-refresh')]),
        button(
          id: 'auto-refresh-toggle',
          type: .button,
          classes: _autoRefresh ? 'toggle on' : 'toggle',
          onClick: () => setState(() {
            _autoRefresh = !_autoRefresh;
            if (_autoRefresh) _startPolling();
          }),
          attributes: {'role': 'switch', 'aria-checked': _autoRefresh ? 'true' : 'false'},
          [span(classes: 'toggle-thumb', [])],
        ),
        button(
          type: .button,
          classes: 'btn-secondary',
          onClick: _loading ? null : () => _fetchOrders(),
          attributes: _loading ? {'disabled': 'true'} : null,
          [.text(_loading ? 'Refreshing…' : 'Refresh')],
        ),
      ]),
      if (_error != null) p(classes: 'error-message', attributes: {'role': 'alert'}, [.text(_error!)]),
      section(classes: 'order-section', [
        h2(classes: 'section-title', [.text('Orders Awaiting Preparation')]),
        if (_createdOrders.isEmpty)
          p(classes: 'text-muted', [.text('No orders awaiting preparation')])
        else
          div(classes: 'card-list', [
            for (final order in _createdOrders) _orderCard(order, showMarkButton: true),
          ]),
      ]),
      section(classes: 'order-section', [
        h2(classes: 'section-title', [.text('Prepared Orders')]),
        if (_preparedOrders.isEmpty)
          p(classes: 'text-muted', [.text('No orders have been prepared')])
        else
          div(classes: 'card-list', [
            for (final order in _preparedOrders) _orderCard(order, showMarkButton: false),
          ]),
      ]),
    ]);
  }
}