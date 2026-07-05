import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/header.dart';
import 'pages/dashboard.dart';
import 'pages/home.dart';
import 'pages/kitchen.dart';
import 'pages/order.dart';
import 'pages/restaurant.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'main', [
      const Header(),
      .element(
        tag: 'main',
        classes: 'content',
        children: [
          Router(
            routes: [
              Route(path: '/', title: 'Home', builder: (context, state) => const Home()),
              Route(
                path: '/dashboard',
                title: 'Dashboard',
                builder: (context, state) => const Dashboard(),
              ),
              Route(
                path: '/restaurant',
                title: 'Restaurant Management',
                builder: (context, state) => const RestaurantPage(),
              ),
              Route(
                path: '/order',
                title: 'Order Management',
                builder: (context, state) => const OrderPage(),
              ),
              Route(
                path: '/kitchen',
                title: 'Kitchen Management',
                builder: (context, state) => const KitchenPage(),
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.main', [
      css('&').styles(
        display: .flex,
        minHeight: 100.vh,
        flexDirection: .column,
      ),
      css('.content').styles(
        display: .flex,
        flexDirection: .column,
        flex: Flex(grow: 1),
      ),
    ]),
  ];
}
