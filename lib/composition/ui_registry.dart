/// Collects UI route and section contributions from vertical slices.
///
/// Populated during composition bootstrap; consumed by [lib/shell/app.dart] in R4.
final class UiRegistry {
  final _contributors = <void Function()>[];

  void register(void Function() contributor) {
    _contributors.add(contributor);
  }

  Iterable<void Function()> get contributors => _contributors;
}
