import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'home-hero', [
      h1([.text('Restaurant Order Management')]),
      p(classes: 'subtitle', [
        .text(
          'Create restaurants, manage menus, place orders, and track preparation.',
        ),
      ]),
      img(
        src: '/images/logo.png',
        width: 1024,
        height: 450,
        alt: 'order',
      ),
      p(classes: 'description', [
        .text('A demo application showcasing the '),
        a(
          href: 'https://github.com/fraktalio/fmodel-decider',
          attributes: {'target': '_blank', 'rel': 'noopener noreferrer'},
          [.text('fmodel-decider')],
        ),
        .text(' library and the '),
        a(
          href: 'https://dcb.events/',
          attributes: {'target': '_blank', 'rel': 'noopener noreferrer'},
          [.text('Dynamic Consistency Boundary (DCB)')],
        ),
        .text(' pattern for event-sourced systems. Built with '),
        a(
          href: 'https://jaspr.site',
          attributes: {'target': '_blank', 'rel': 'noopener noreferrer'},
          [.text('Jaspr')],
        ),
        .text(', Dart, and '),
        a(
          href: 'https://www.sqlite.org/',
          attributes: {'target': '_blank', 'rel': 'noopener noreferrer'},
          [.text('SQLite')],
        ),
        .text('.'),
      ]),
    ]);
  }
}
