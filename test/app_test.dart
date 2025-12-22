import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/features/home/presentation/home_page.dart';
import 'package:mealtrack/features/scanner/service/text_recognition_service.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockTextRecognitionService extends Mock
    implements TextRecognitionService {}

void main() {
  testWidgets('MealTrackApp builds and displays HomePage', (tester) async {
    final mockImagePicker = MockImagePicker();
    final mockTextRecognitionService = MockTextRecognitionService();

    await tester.pumpWidget(
      MealTrackApp(
        imagePicker: mockImagePicker,
        textRecognitionService: mockTextRecognitionService,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}
