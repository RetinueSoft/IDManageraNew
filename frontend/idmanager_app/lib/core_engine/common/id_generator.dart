/// Generates short, unique, monotonically-increasing client-side ids for things
/// that need a stable identity before they're ever saved to the backend (e.g. a
/// newly-added, not-yet-saved layer group on the designer canvas) - mirrors the
/// role a ULID generator plays elsewhere, without pulling in a package for it.
class IdGenerator {
  static int _counter = 0;

  static String generate() {
    _counter++;
    return '${DateTime.now().microsecondsSinceEpoch}-$_counter';
  }
}
