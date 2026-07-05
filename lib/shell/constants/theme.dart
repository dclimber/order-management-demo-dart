import 'package:jaspr/dom.dart';

// CSS custom property values (HSL components without the hsl() wrapper).
const backgroundHsl = '0 0% 100%';
const foregroundHsl = '222.2 47.4% 11.2%';
const mutedForegroundHsl = '215.4 16.3% 46.9%';
const borderHsl = '214.3 31.8% 91.4%';

const darkBackgroundHsl = '224 71% 4%';
const darkForegroundHsl = '213 31% 91%';
const darkMutedForegroundHsl = '215.4 16.3% 56.9%';
const darkBorderHsl = '216 34% 17%';
const linkColor = Color('#2563eb');
const linkColorHover = Color('#1d4ed8');
const mutedTextColor = Color('#4b5563');
const borderColor = Color('#e5e7eb');

@css
List<StyleRule> get styles => [
  css.fontFace(
    family: 'Fixel',
    url: '/fonts/FixelVariable.woff2',
  ),
  css.fontFace(
    family: 'Fixel',
    style: .italic,
    url: '/fonts/FixelVariableItalic.woff2',
  ),
  css(':root').styles(
    raw: {
      '--background': backgroundHsl,
      '--foreground': foregroundHsl,
      '--muted-foreground': mutedForegroundHsl,
      '--border': borderHsl,
      '--radius': '0.5rem',
    },
  ),
  css('html.dark').styles(
    raw: {
      '--background': darkBackgroundHsl,
      '--foreground': darkForegroundHsl,
      '--muted-foreground': darkMutedForegroundHsl,
      '--border': darkBorderHsl,
    },
  ),
  css('html, body').styles(
    width: 100.percent,
    minHeight: 100.vh,
    padding: .zero,
    margin: .zero,
    raw: {
      'background-color': 'hsl(var(--background))',
      'color': 'hsl(var(--foreground))',
    },
    fontFamily: const .list([
      FontFamily('Fixel'),
      FontFamily('system-ui'),
      FontFamilies.sansSerif,
    ]),
    fontSize: 1.125.rem,
    lineHeight: 1.5.em,
  ),
  css('h1, h2, h3, h4, h5, h6').styles(
    margin: .unset,
    fontWeight: .w700,
  ),
  css('a').styles(
    color: linkColor,
    textDecoration: TextDecoration(line: .none),
  ),
  css('a:hover').styles(
    textDecoration: TextDecoration(line: .underline),
  ),
  css('.text-muted').styles(
    raw: {'color': 'hsl(var(--muted-foreground))'},
  ),
  css('.page-container').styles(
    width: 100.percent,
    maxWidth: 48.rem,
    margin: Margin.symmetric(horizontal: .auto),
    padding: Padding.symmetric(horizontal: 1.rem, vertical: 2.rem),
  ),
  css('.page-title').styles(
    fontSize: 1.5.rem,
    fontWeight: .w700,
    margin: Margin.only(bottom: 2.rem),
  ),
  css('.home-hero').styles(
    width: 100.percent,
    flex: Flex(grow: 1),
    display: .flex,
    flexDirection: .column,
    alignItems: .center,
    justifyContent: .center,
    padding: Padding.symmetric(horizontal: 1.rem, vertical: 2.rem),
  ),
  css('.home-hero h1').styles(
    fontSize: 2.25.rem,
    textAlign: .center,
  ),
  css('.home-hero .subtitle').styles(
    margin: Margin.only(top: 0.75.rem),
    maxWidth: 42.rem,
    textAlign: .center,
    color: mutedTextColor,
  ),
  css('.home-hero .description').styles(
    margin: Margin.only(top: 1.rem),
    maxWidth: 42.rem,
    textAlign: .center,
    fontSize: 1.125.rem,
  ),
  css('.home-hero img').styles(
    margin: Margin.symmetric(vertical: 1.5.rem),
    maxWidth: 100.percent,
    height: .auto,
  ),
  css('.home-hero a').styles(
    color: linkColor,
    textDecoration: TextDecoration(line: .underline),
  ),
  css('.home-hero a:hover').styles(
    color: linkColorHover,
  ),
  css('.section-title').styles(
    fontSize: 1.25.rem,
    fontWeight: .w600,
    margin: Margin.only(bottom: 1.rem),
  ),
  css('.page-section').styles(
    margin: Margin.only(bottom: 2.rem),
  ),
  css('.section-divider').styles(
    margin: Margin.symmetric(vertical: 2.rem),
    border: .only(
      top: BorderSide.solid(color: borderColor, width: 1.px),
    ),
  ),
  css('.lookup-form').styles(
    display: .flex,
    flexWrap: .wrap,
    alignItems: .end,
    gap: Gap.all(0.75.rem),
    margin: Margin.only(bottom: 1.5.rem),
  ),
  css('.lookup-form label').styles(
    display: .block,
    width: 100.percent,
    fontSize: 0.875.rem,
    fontWeight: .w500,
  ),
  css('.lookup-form input').styles(
    minWidth: 16.rem,
    padding: Padding.symmetric(horizontal: 0.75.rem, vertical: 0.5.rem),
    radius: .all(Radius.circular(0.375.rem)),
    border: .all(style: .solid, color: borderColor, width: 1.px),
  ),
  css('.lookup-form button').styles(
    padding: Padding.symmetric(horizontal: 1.rem, vertical: 0.5.rem),
    radius: .all(Radius.circular(0.375.rem)),
    border: .unset,
    backgroundColor: linkColor,
    color: Colors.white,
    cursor: .pointer,
    fontWeight: .w500,
  ),
  css('.data-card').styles(
    padding: Padding.all(1.rem),
    radius: .all(Radius.circular(0.5.rem)),
    border: .all(style: .solid, color: borderColor, width: 1.px),
    margin: Margin.only(top: 1.rem),
  ),
  css('.data-list').styles(
    margin: .zero,
  ),
  css('.data-list > div').styles(
    margin: Margin.only(bottom: 0.75.rem),
  ),
  css('.data-list dt').styles(
    fontWeight: .w600,
    fontSize: 0.875.rem,
  ),
  css('.data-list dd').styles(
    margin: Margin.only(left: 0.px, top: 0.25.rem),
  ),
  css('.item-list').styles(
    margin: Margin.only(top: 0.25.rem),
    padding: Padding.only(left: 1.25.rem),
  ),
  css('.status-badge').styles(
    display: .inlineBlock,
    padding: Padding.symmetric(horizontal: 0.5.rem, vertical: 0.125.rem),
    radius: .all(Radius.circular(9999.px)),
    fontSize: 0.75.rem,
    fontWeight: .w600,
  ),
  css('.status-badge.created').styles(
    backgroundColor: Color('#fef3c7'),
    color: Color('#92400e'),
  ),
  css('.status-badge.prepared').styles(
    backgroundColor: Color('#dcfce7'),
    color: Color('#166534'),
  ),
  css('.error-message').styles(
    color: Color('#dc2626'),
    margin: Margin.only(top: 1.rem),
  ),
  css('.card-list').styles(
    display: .flex,
    flexDirection: .column,
    gap: Gap.all(0.75.rem),
  ),
  css('.order-section').styles(
    margin: Margin.only(bottom: 2.rem),
  ),
  css('.stats-grid').styles(
    display: .flex,
    flexWrap: .wrap,
    gap: Gap.all(1.rem),
    margin: Margin.symmetric(vertical: 1.5.rem),
  ),
  css('.stat-card').styles(
    flex: Flex(grow: 1),
    minWidth: 8.rem,
    padding: Padding.all(1.rem),
    radius: .all(Radius.circular(0.5.rem)),
    border: .all(style: .solid, color: borderColor, width: 1.px),
    textAlign: .center,
  ),
  css('.stat-value').styles(
    fontSize: 2.rem,
    fontWeight: .w700,
    margin: Margin.only(bottom: 0.25.rem),
  ),
  css('.stat-label').styles(
    fontSize: 0.875.rem,
    raw: {'color': 'hsl(var(--muted-foreground))'},
  ),
  css('.link-list').styles(
    padding: Padding.only(left: 1.25.rem),
  ),
  css('.phase-note').styles(
    margin: Margin.only(top: 2.rem),
    fontSize: 0.875.rem,
  ),
  css('.client-form').styles(
    margin: Margin.only(bottom: 2.rem),
  ),
  css('.form-grid').styles(
    display: .flex,
    flexWrap: .wrap,
    gap: Gap.all(1.rem),
    margin: Margin.only(bottom: 1.rem),
  ),
  css('.form-grid > .form-field').styles(
    flex: Flex(grow: 1),
    minWidth: 12.rem,
  ),
  css('.form-field').styles(
    display: .flex,
    flexDirection: .column,
    gap: Gap.all(0.25.rem),
    margin: Margin.only(bottom: 1.rem),
  ),
  css('.form-field.grow').styles(
    flex: Flex(grow: 1),
  ),
  css('.form-field input, .form-field select').styles(
    width: 100.percent,
    padding: Padding.symmetric(horizontal: 0.75.rem, vertical: 0.5.rem),
    radius: .all(Radius.circular(0.375.rem)),
    border: .all(style: .solid, color: borderColor, width: 1.px),
    boxSizing: .borderBox,
  ),
  css('.form-legend').styles(
    fontSize: 0.875.rem,
    fontWeight: .w500,
    margin: Margin.only(bottom: 0.5.rem),
  ),
  css('.menu-item-row').styles(
    display: .flex,
    flexWrap: .wrap,
    alignItems: .end,
    gap: Gap.all(0.75.rem),
    margin: Margin.only(bottom: 0.75.rem),
  ),
  css('.price-field').styles(
    width: 7.rem,
  ),
  css('.input-with-button').styles(
    display: .flex,
    gap: Gap.all(0.5.rem),
  ),
  css('.btn-primary').styles(
    padding: Padding.symmetric(horizontal: 1.rem, vertical: 0.5.rem),
    radius: .all(Radius.circular(0.375.rem)),
    border: .unset,
    backgroundColor: linkColor,
    color: Colors.white,
    cursor: .pointer,
    fontWeight: .w500,
  ),
  css('.btn-secondary').styles(
    padding: Padding.symmetric(horizontal: 1.rem, vertical: 0.5.rem),
    radius: .all(Radius.circular(0.375.rem)),
    border: .all(style: .solid, color: borderColor, width: 1.px),
    backgroundColor: Colors.white,
    cursor: .pointer,
  ),
  css('.btn-ghost').styles(
    padding: Padding.symmetric(horizontal: 0.75.rem, vertical: 0.5.rem),
    radius: .all(Radius.circular(0.375.rem)),
    border: .unset,
    backgroundColor: Colors.transparent,
    cursor: .pointer,
  ),
  css('.btn-danger').styles(
    padding: Padding.symmetric(horizontal: 0.75.rem, vertical: 0.5.rem),
    radius: .all(Radius.circular(0.375.rem)),
    border: .unset,
    backgroundColor: Color('#dc2626'),
    color: Colors.white,
    cursor: .pointer,
  ),
  css('.success-message').styles(
    color: Color('#16a34a'),
    margin: Margin.only(bottom: 1.rem),
  ),
  css('.menu-table').styles(
    width: 100.percent,
    raw: {'border-collapse': 'collapse'},
    fontSize: 0.875.rem,
  ),
  css('.menu-table th, .menu-table td').styles(
    padding: Padding.symmetric(horizontal: 0.75.rem, vertical: 0.5.rem),
    border: .all(style: .solid, color: borderColor, width: 1.px),
    textAlign: .left,
  ),
  css('.kitchen-controls').styles(
    display: .flex,
    alignItems: .center,
    gap: Gap.all(1.rem),
    margin: Margin.only(bottom: 1.5.rem),
  ),
  css('.kitchen-order-card').styles(
    display: .flex,
    flexDirection: .column,
    gap: Gap.all(1.rem),
  ),
  css('.toggle').styles(
    width: 2.75.rem,
    height: 1.5.rem,
    radius: .all(Radius.circular(9999.px)),
    border: .unset,
    backgroundColor: Color('#d1d5db'),
    cursor: .pointer,
    position: .relative(),
    padding: .zero,
  ),
  css('.toggle.on').styles(
    backgroundColor: linkColor,
  ),
  css('.toggle-thumb').styles(
    display: .block,
    width: 1.rem,
    height: 1.rem,
    radius: .all(Radius.circular(9999.px)),
    backgroundColor: Colors.white,
    position: .absolute(top: 0.25.rem, left: 0.25.rem),
    raw: {'transition': 'transform 0.2s ease'},
  ),
  css('.toggle.on .toggle-thumb').styles(
    raw: {'transform': 'translateX(1.25rem)'},
  ),
  css('.user-welcome').styles(
    display: .flex,
    alignItems: .center,
    gap: Gap.all(1.rem),
    margin: Margin.only(bottom: 1.5.rem),
  ),
  css('.user-avatar').styles(
    radius: .all(Radius.circular(9999.px)),
  ),
  css('.auth-link a').styles(
    fontWeight: .w500,
  ),
  css('.logo .logo-dark').styles(
    display: .none,
  ),
  css('html.dark .logo .logo-light').styles(
    display: .none,
  ),
  css('html.dark .logo .logo-dark').styles(
    display: .block,
  ),
  css('html.dark a').styles(
    color: Color('#60a5fa'),
  ),
  css('html.dark a:hover').styles(
    color: Color('#93c5fd'),
  ),
  css('html.dark .home-hero .subtitle').styles(
    raw: {'color': 'hsl(var(--muted-foreground))'},
  ),
  css('html.dark .section-divider').styles(
    raw: {'border-top': '1px solid hsl(var(--border))'},
  ),
  css('html.dark .data-card, html.dark .stat-card').styles(
    raw: {'border': '1px solid hsl(var(--border))'},
  ),
  css('html.dark .lookup-form input, html.dark .form-field input, html.dark .form-field select').styles(
    raw: {
      'background-color': 'hsl(var(--background))',
      'color': 'hsl(var(--foreground))',
      'border-color': 'hsl(var(--border))',
    },
  ),
  css('html.dark .btn-secondary').styles(
    raw: {
      'background-color': 'hsl(var(--background))',
      'color': 'hsl(var(--foreground))',
      'border-color': 'hsl(var(--border))',
    },
  ),
  css('html.dark .menu-table th, html.dark .menu-table td').styles(
    raw: {'border': '1px solid hsl(var(--border))'},
  ),
  css('html.dark .toggle').styles(
    backgroundColor: Color('#4b5563'),
  ),
];
