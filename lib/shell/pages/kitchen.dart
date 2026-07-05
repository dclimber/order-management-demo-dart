import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../api.dart';
import '../../composition/app_context.dart';
import '../../vertical_slices/mark_order_as_prepared/ui/ui.dart';
import '../../vertical_slices/order_view/ui/ui.dart';

class KitchenPage extends AsyncStatelessComponent {
  const KitchenPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final createdOrders = await appServices.queryOrdersByStatus(OrderStatus.created);
    final preparedOrders = await appServices.queryOrdersByStatus(OrderStatus.prepared);

    return div(classes: 'page-container', [
      h1(classes: 'page-title', [.text('Kitchen Management')]),
      KitchenDashboard(
        initialCreatedOrders: encodedOrders(createdOrders),
        initialPreparedOrders: encodedOrders(preparedOrders),
      ),
    ]);
  }
}
