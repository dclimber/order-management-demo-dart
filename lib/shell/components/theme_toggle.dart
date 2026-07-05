import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

@client
class ThemeToggle extends StatefulComponent {
  const ThemeToggle({super.key});

  @override
  State<ThemeToggle> createState() => ThemeToggleState();

  @css
  static List<StyleRule> get styles => [
    css('.theme-toggle', [
      css('&').styles(
        display: .inlineFlex,
        alignItems: .center,
        justifyContent: .center,
        padding: Padding.all(0.25.rem),
        border: .unset,
        backgroundColor: Colors.transparent,
        cursor: .pointer,
        raw: {'color': 'hsl(var(--muted-foreground))'},
      ),
      css('&:hover').styles(
        raw: {'color': '#eab308'},
      ),
      css('& svg').styles(
        width: 1.5.rem,
        height: 1.5.rem,
      ),
    ]),
  ];
}

class ThemeToggleState extends State<ThemeToggle> {
  var _isDark = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _isDark = web.document.documentElement?.classList.contains('dark') ?? false;
    }
  }

  void _toggleTheme() {
    if (!kIsWeb) return;

    final root = web.document.documentElement;
    if (root == null) return;

    if (_isDark) {
      root.classList.remove('dark');
      web.window.localStorage.setItem('theme', 'light');
    } else {
      root.classList.add('dark');
      web.window.localStorage.setItem('theme', 'dark');
    }
    setState(() => _isDark = !_isDark);
  }

  @override
  Component build(BuildContext context) {
    return button(
      type: .button,
      classes: 'theme-toggle',
      events: {
        'click': (_) => _toggleTheme(),
      },
      attributes: {'aria-label': _isDark ? 'Switch to light mode' : 'Switch to dark mode'},
      [
        if (_isDark) _darkIcon() else _lightIcon(),
      ],
    );
  }

  Component _lightIcon() {
    return svg(
      attributes: {
        'xmlns': 'http://www.w3.org/2000/svg',
        'fill': 'none',
        'viewBox': '0 0 24 24',
        'stroke-width': '1.5',
        'stroke': 'currentColor',
        'aria-hidden': 'true',
      },
      [
        path(
          d: 'M12 3v2.25m6.364.386-1.591 1.591M21 12h-2.25m-.386 6.364-1.591-1.591M12 18.75V21m-4.773-4.227-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z',
          attributes: {
            'stroke-linecap': 'round',
            'stroke-linejoin': 'round',
          },
          const [],
        ),
      ],
    );
  }

  Component _darkIcon() {
    return svg(
      attributes: {
        'xmlns': 'http://www.w3.org/2000/svg',
        'fill': 'none',
        'viewBox': '0 0 24 24',
        'stroke-width': '1.5',
        'stroke': 'currentColor',
        'aria-hidden': 'true',
      },
      [
        path(
          d: 'M21.752 15.002A9.72 9.72 0 0 1 18 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 0 0 3 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 0 0 9.002-5.998Z',
          attributes: {
            'stroke-linecap': 'round',
            'stroke-linejoin': 'round',
          },
          const [],
        ),
      ],
    );
  }
}
