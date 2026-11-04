
class RegistrationRetrievalException implements Exception {
  final String message;

  RegistrationRetrievalException(this.message);

  @override
  String toString() => "RegistrationRetrievalException: $message";
}