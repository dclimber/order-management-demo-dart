import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../api.dart';
import '../../composition/app_context.dart';
import '../../platform/auth/session_context.dart';

class Dashboard extends AsyncStatelessComponent {
  const Dashboard({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final user = currentSessionUser!;
    final restaurants = await appServices.queryAllRestaurants();
    final awaiting = await appServices.queryOrdersByStatus(OrderStatus.created);
    final prepared = await appServices.queryOrdersByStatus(OrderStatus.prepared);

    return div(classes: 'page-container', [
      div(classes: 'user-welcome', [
        img(
          src: user.avatarUrl,
          alt: "${user.name}'s avatar",
          width: 48,
          height: 48,
          classes: 'user-avatar',
        ),
        div([
          h1(classes: 'page-title', [.text('Welcome, ${user.name}')]),
          p(classes: 'text-muted', [.text('@${user.login}')]),
        ]),
      ]),
      p([.text('This is a protected page. Only signed-in users can see this.')]),
      a(href: '/signout', [.text('Sign out')]),
      div(classes: 'stats-grid', [
        _statCard('Restaurants', restaurants.length.toString()),
        _statCard('Awaiting Preparation', awaiting.length.toString()),
        _statCard('Prepared Orders', prepared.length.toString()),
      ]),
      h2(classes: 'section-title', [.text('Quick Links')]),
      ul(classes: 'link-list', [
        li([
          a(href: '/restaurant', [.text('Restaurant Management')]),
        ]),
        li([
          a(href: '/order', [.text('Order Management')]),
        ]),
        li([
          a(href: '/kitchen', [.text('Kitchen Management')]),
        ]),
      ]),
      if (restaurants.isNotEmpty) h2(classes: 'section-title', [.text('Recent Restaurants')]),
      if (restaurants.isNotEmpty)
        ul(classes: 'link-list', [
          for (final restaurant in restaurants)
            li([
              a(
                href: '/restaurant?restaurantId=${restaurant.restaurantId.value}',
                [.text(restaurant.name.value)],
              ),
            ]),
        ]),
    ]);
  }

  Component _statCard(String label, String value) {
    return div(classes: 'stat-card', [
      p(classes: 'stat-value', [.text(value)]),
      p(classes: 'stat-label', [.text(label)]),
    ]);
  }
}
