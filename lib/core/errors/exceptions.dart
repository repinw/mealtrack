/// Exception thrown when receipt analysis fails.
/// This includes errors from the AI service, network issues during analysis,
/// or failure to interpret the result (e.g., empty text).
class ReceiptAnalysisException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  ReceiptAnalysisException(this.message, {this.code, this.originalException});

  @override
  String toString() =>
      'ReceiptAnalysisException: $message${code != null ? ' (Code: $code)' : ''}';
}
