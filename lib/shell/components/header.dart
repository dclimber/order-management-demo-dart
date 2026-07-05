import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../platform/auth/session_context.dart';
import 'theme_toggle.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  static const _routes = [
    (label: 'Home', path: '/'),
    (label: 'Dashboard', path: '/dashboard'),
    (label: 'Restaurant', path: '/restaurant'),
    (label: 'Order', path: '/order'),
    (label: 'Kitchen', path: '/kitchen'),
  ];

  bool _isActive(String activePath, String path) {
    if (path == '/') return activePath == '/';
    return activePath == path || activePath.startsWith('$path/');
  }

  @override
  Component build(BuildContext context) {
    final activePath = context.url;

    return header(classes: 'app-header', [
      a(
        href: '/',
        classes: 'logo',
        attributes: {'aria-label': 'Home'},
        [
          img(
            src: '/images/logo.webp',
            alt: 'Fraktalio logo',
            classes: 'logo-light',
            width: 14,
            height: 18,
          ),
          img(
            src: '/images/logo-white.webp',
            alt: 'Fraktalio logo',
            classes: 'logo-dark',
            width: 14,
            height: 28,
          ),
          .text('{ restaurant }'),
        ],
      ),
      nav(classes: 'nav', [
        for (final route in _routes)
          div(
            classes: _isActive(activePath, route.path) ? 'nav-item active' : 'nav-item',
            [
              Link(
                to: route.path,
                child: .text(route.label),
              ),
            ],
          ),
        div(classes: 'nav-item', [
          const ThemeToggle(),
        ]),
        div(classes: 'nav-item auth-link', [
          if (currentSessionUser != null)
            a(href: '/signout', [.text('Sign out')])
          else
            a(href: '/signin', [.text('Sign in')]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.app-header', [
      css('&').styles(
        display: .flex,
        alignItems: .center,
        justifyContent: .spaceBetween,
        gap: Gap.all(1.5.rem),
        width: 100.percent,
        maxWidth: 96.rem,
        height: 5.rem,
        margin: Margin.symmetric(horizontal: .auto),
        padding: Padding.symmetric(horizontal: 1.rem),
        position: .sticky(top: 0.px),
        zIndex: ZIndex(50),
        raw: {
          'background-color': 'hsl(var(--background) / 0.75)',
          'color': 'hsl(var(--muted-foreground))',
          'backdrop-filter': 'blur(4px)',
        },
      ),
      css('.logo').styles(
        display: .flex,
        alignItems: .center,
        gap: Gap.all(0.75.rem),
        fontWeight: .w700,
        raw: {'color': 'hsl(var(--foreground))'},
        textDecoration: TextDecoration(line: .none),
      ),
      css('.logo:hover').styles(
        textDecoration: TextDecoration(line: .none),
      ),
      css('.nav').styles(
        display: .flex,
        alignItems: .center,
        flexWrap: .wrap,
        gap: Gap.all(0.25.rem),
      ),
      css('.nav-item a').styles(
        display: .flex,
        padding: Padding.symmetric(horizontal: 0.75.rem, vertical: 0.5.rem),
        raw: {'color': 'hsl(var(--muted-foreground))'},
        textDecoration: TextDecoration(line: .none),
        fontWeight: .w400,
      ),
      css('.nav-item a:hover').styles(
        textDecoration: TextDecoration(line: .underline),
        raw: {'color': 'hsl(var(--foreground))'},
      ),
      css('.nav-item.active a').styles(
        fontWeight: .w700,
        raw: {'color': 'hsl(var(--foreground))'},
      ),
    ]),
  ];
}
