// Typed network exceptions
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error']);

  @override
  String toString() => 'NetworkException: $message';
}

class ApiException implements Exception {
  final String message;
  final int? code;
  ApiException(this.message, {this.code});

  @override
  String toString() => 'ApiException(code:$code): $message';
}

class ParsingException implements Exception {
  final String message;
  ParsingException([this.message = 'Parsing error']);

  @override
  String toString() => 'ParsingException: $message';
}
