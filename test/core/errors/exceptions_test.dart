import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/errors/exceptions.dart';

void main() {
  test('ReceiptAnalysisException toString works correctly', () {
    final exception1 = ReceiptAnalysisException('Message');
    expect(exception1.toString(), 'ReceiptAnalysisException: Message');

    final exception2 = ReceiptAnalysisException('Message', code: '500');
    expect(
      exception2.toString(),
      'ReceiptAnalysisException: Message (Code: 500)',
    );

    expect(exception2.originalException, isNull);
  });
}
