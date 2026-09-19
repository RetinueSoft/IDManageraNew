/// Thrown by Business Services when a create/update fails validation.
/// [errors] maps field name to the user-facing message for that field.
class ValidationException implements Exception {
  ValidationException(this.errors);

  final Map<String, String> errors;

  @override
  String toString() => errors.values.join(' ');
}
