import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mealtrack/features/scanner/service/image_compressor.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MockImageCompressor extends Mock implements ImageCompressor {}

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

class MockXFile extends Mock implements XFile {}

class FakeRemoteConfigSettings extends Fake implements RemoteConfigSettings {}

abstract class GenerativeModelInterface {
  Future<GenerateContentResponseInterface> generateContent(
    String templateId, {
    Map<String, dynamic>? inputs,
  });
}

abstract class GenerateContentResponseInterface {
  String? get text;
}

class MockGenerativeModel extends Mock implements GenerativeModelInterface {}

class MockGenerateContentResponse extends Mock
    implements GenerateContentResponseInterface {}

void main() {
  setUpAll(() {
    registerFallbackValue(CompressFormat.jpeg);
    registerFallbackValue(FakeRemoteConfigSettings());
  });

  group('FirebaseAiService', () {
    late FirebaseAiService service;
    late MockImageCompressor mockImageCompressor;
    late MockFirebaseRemoteConfig mockRemoteConfig;
    late MockXFile mockXFile;
    late MockGenerativeModel mockGenerativeModel;

    setUp(() {
      mockImageCompressor = MockImageCompressor();
      mockRemoteConfig = MockFirebaseRemoteConfig();
      mockXFile = MockXFile();
      mockGenerativeModel = MockGenerativeModel();

      when(() => mockXFile.path).thenReturn('test/path/image.jpg');
      when(() => mockXFile.length()).thenAnswer((_) async => 1000);
      when(
        () => mockXFile.readAsBytes(),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));

      when(
        () => mockImageCompressor.compressWithFile(
          any(),
          minWidth: any(named: 'minWidth'),
          minHeight: any(named: 'minHeight'),
          quality: any(named: 'quality'),
          format: any(named: 'format'),
        ),
      ).thenAnswer((_) async => Uint8List(10));
    });

    group('initialize', () {
      test('sets config settings and fetches remote config', () async {
        final configUpdatedController =
            StreamController<RemoteConfigUpdate>.broadcast();

        when(
          () => mockRemoteConfig.setConfigSettings(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteConfig.setDefaults(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteConfig.fetchAndActivate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemoteConfig.onConfigUpdated,
        ).thenAnswer((_) => configUpdatedController.stream);
        when(() => mockRemoteConfig.activate()).thenAnswer((_) async => true);

        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        await service.initialize();

        verify(() => mockRemoteConfig.setConfigSettings(any())).called(1);
        verify(() => mockRemoteConfig.setDefaults(any())).called(1);
        verify(() => mockRemoteConfig.fetchAndActivate()).called(1);

        await configUpdatedController.close();
      });

      test('listens to config updates and activates on change', () async {
        final configUpdatedController =
            StreamController<RemoteConfigUpdate>.broadcast();

        when(
          () => mockRemoteConfig.setConfigSettings(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteConfig.setDefaults(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteConfig.fetchAndActivate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemoteConfig.onConfigUpdated,
        ).thenAnswer((_) => configUpdatedController.stream);
        when(() => mockRemoteConfig.activate()).thenAnswer((_) async => true);

        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        await service.initialize();

        configUpdatedController.add(RemoteConfigUpdate({'template_id'}));

        await Future<void>.delayed(Duration.zero);

        verify(() => mockRemoteConfig.activate()).called(1);

        await configUpdatedController.close();
      });
    });

    test(
      'analyzeImageWithGemini calls compression before analyzing (Config Failure)',
      () async {
        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
          modelProvider: () => mockGenerativeModel,
        );

        when(
          () => mockRemoteConfig.getString("template_id"),
        ).thenThrow(Exception("Config reached"));

        await expectLater(
          () => service.analyzeImageWithGemini(mockXFile),
          throwsA(predicate((e) => e.toString().contains('Config reached'))),
        );

        verify(
          () => mockImageCompressor.compressWithFile(
            any(),
            minWidth: any(named: 'minWidth'),
            minHeight: any(named: 'minHeight'),
            quality: any(named: 'quality'),
            format: any(named: 'format'),
          ),
        ).called(1);
      },
    );

    test('analyzeImageWithGemini returns text on success', () async {
      const templateId = 'valid_template_id';
      const expectedText = 'Receipt Data';

      final mockResponse = MockGenerateContentResponse();
      when(() => mockResponse.text).thenReturn(expectedText);

      service = FirebaseAiService(
        imageCompressor: mockImageCompressor,
        remoteConfig: mockRemoteConfig,
        modelProvider: () => mockGenerativeModel,
      );

      when(
        () => mockRemoteConfig.getString("template_id"),
      ).thenReturn(templateId);

      when(
        () => mockGenerativeModel.generateContent(
          templateId,
          inputs: any(named: 'inputs'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.analyzeImageWithGemini(mockXFile);

      expect(result, expectedText);

      verify(() => mockRemoteConfig.getString("template_id")).called(1);
      verify(
        () => mockImageCompressor.compressWithFile(
          any(),
          minWidth: any(named: 'minWidth'),
          minHeight: any(named: 'minHeight'),
          quality: any(named: 'quality'),
          format: any(named: 'format'),
        ),
      ).called(1);
    });

    test(
      'analyzeImageWithGemini throws NO_TEXT when AI returns empty text',
      () async {
        const templateId = 'valid_template_id';

        final mockResponse = MockGenerateContentResponse();
        when(() => mockResponse.text).thenReturn('');

        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
          modelProvider: () => mockGenerativeModel,
        );

        when(
          () => mockRemoteConfig.getString("template_id"),
        ).thenReturn(templateId);

        when(
          () => mockGenerativeModel.generateContent(
            templateId,
            inputs: any(named: 'inputs'),
          ),
        ).thenAnswer((_) async => mockResponse);

        await expectLater(
          () => service.analyzeImageWithGemini(mockXFile),
          throwsA(
            isA<ReceiptAnalysisException>().having(
              (e) => e.code,
              'code',
              'NO_TEXT',
            ),
          ),
        );
      },
    );

    test(
      'analyzeImageWithGemini throws NO_TEXT when AI returns null text',
      () async {
        const templateId = 'valid_template_id';

        final mockResponse = MockGenerateContentResponse();
        when(() => mockResponse.text).thenReturn(null); 

        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
          modelProvider: () => mockGenerativeModel,
        );

        when(
          () => mockRemoteConfig.getString("template_id"),
        ).thenReturn(templateId);

        when(
          () => mockGenerativeModel.generateContent(
            templateId,
            inputs: any(named: 'inputs'),
          ),
        ).thenAnswer((_) async => mockResponse);

        await expectLater(
          () => service.analyzeImageWithGemini(mockXFile),
          throwsA(
            isA<ReceiptAnalysisException>().having(
              (e) => e.code,
              'code',
              'NO_TEXT',
            ),
          ),
        );
      },
    );

    test('analyzeImageWithGemini throws AI_ERROR when model fails', () async {
      const templateId = 'valid_template_id';

      service = FirebaseAiService(
        imageCompressor: mockImageCompressor,
        remoteConfig: mockRemoteConfig,
        modelProvider: () => mockGenerativeModel,
      );

      when(
        () => mockRemoteConfig.getString("template_id"),
      ).thenReturn(templateId);

      when(
        () => mockGenerativeModel.generateContent(
          templateId,
          inputs: any(named: 'inputs'),
        ),
      ).thenThrow(Exception('API Error'));

      await expectLater(
        () => service.analyzeImageWithGemini(mockXFile),
        throwsA(
          isA<ReceiptAnalysisException>().having(
            (e) => e.code,
            'code',
            'AI_ERROR',
          ),
        ),
      );
    });

    test(
      'analyzeImageWithGemini Error Path: throws ReceiptAnalysisException when compression fails (returns null)',
      () async {
        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
        );

        when(
          () => mockImageCompressor.compressWithFile(
            any(),
            minWidth: any(named: 'minWidth'),
            minHeight: any(named: 'minHeight'),
            quality: any(named: 'quality'),
            format: any(named: 'format'),
          ),
        ).thenAnswer((_) async => null);

        await expectLater(
          () => service.analyzeImageWithGemini(mockXFile),
          throwsA(
            isA<ReceiptAnalysisException>().having(
              (e) => e.code,
              'code',
              'COMPRESSION_ERROR',
            ),
          ),
        );
      },
    );

    test(
      'uses fallback template ID when remote config returns empty',
      () async {
        final mockResponse = MockGenerateContentResponse();
        when(() => mockResponse.text).thenReturn('Success');

        service = FirebaseAiService(
          imageCompressor: mockImageCompressor,
          remoteConfig: mockRemoteConfig,
          modelProvider: () => mockGenerativeModel,
        );

        when(() => mockRemoteConfig.getString('template_id')).thenReturn('');
        when(
          () => mockGenerativeModel.generateContent(
            'receiptocr',
            inputs: any(named: 'inputs'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await service.analyzeImageWithGemini(mockXFile);
        expect(result, 'Success');

        verify(() => mockRemoteConfig.getString('template_id')).called(1);
      },
    );

    test('analyzePdfWithGemini Happy Path', () async {
      const templateId = 'valid_template_id';
      const expectedText = 'PDF Data';

      final mockResponse = MockGenerateContentResponse();
      when(() => mockResponse.text).thenReturn(expectedText);

      service = FirebaseAiService(
        imageCompressor: mockImageCompressor,
        remoteConfig: mockRemoteConfig,
        modelProvider: () => mockGenerativeModel,
      );

      when(
        () => mockRemoteConfig.getString("template_id"),
      ).thenReturn(templateId);

      when(
        () => mockGenerativeModel.generateContent(
          templateId,
          inputs: any(named: 'inputs'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.analyzePdfWithGemini(mockXFile);

      expect(result, expectedText);
    });
  });
}
