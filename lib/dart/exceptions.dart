class NotLoggedInException implements Exception {}

class InvalidServerResponseException implements Exception {
  String reason;
  InvalidServerResponseException({required this.reason});

  @override
  String toString() {
    return reason;
  }
}
