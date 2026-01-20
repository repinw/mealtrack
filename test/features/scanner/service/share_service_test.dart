import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/service/share_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class MockReceiveSharingIntent extends Mock implements ReceiveSharingIntent {}

void main() {
  late MockReceiveSharingIntent mockIntent;
  late StreamController<List<SharedMediaFile>> controller;

  setUp(() {
    mockIntent = MockReceiveSharingIntent();
    controller = StreamController<List<SharedMediaFile>>();

    when(
      () => mockIntent.getMediaStream(),
    ).thenAnswer((_) => controller.stream);
    when(() => mockIntent.getInitialMedia()).thenAnswer((_) async => []);
  });

  tearDown(() {
    controller.close();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [receiveSharingIntentProvider.overrideWithValue(mockIntent)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ShareService', () {
    test('ignores empty media stream', () async {
      final container = makeContainer();

      // Initialize service
      await container.read(shareServiceProvider.future);

      // Emit empty list
      controller.add([]);

      // Wait a bit for processing
      await Future.delayed(Duration.zero);

      final sharedFile = container.read(latestSharedFileProvider);
      expect(sharedFile, isNull);
    });

    test('updates latestSharedFileProvider when media is received', () async {
      final container = makeContainer();
      await container.read(shareServiceProvider.future);

      final mediaFile = SharedMediaFile(
        path: 'test.jpg',
        type: SharedMediaType.image,
      );

      controller.add([mediaFile]);

      // Wait for async processing
      await Future.delayed(Duration.zero);

      final sharedFile = container.read(latestSharedFileProvider);
      expect(sharedFile, isNotNull);
      expect(sharedFile!.path, 'test.jpg');
    });

    test('handles initial media (cold start)', () async {
      final mediaFile = SharedMediaFile(
        path: 'initial.jpg',
        type: SharedMediaType.image,
      );
      when(
        () => mockIntent.getInitialMedia(),
      ).thenAnswer((_) async => [mediaFile]);

      final container = makeContainer();
      await container.read(shareServiceProvider.future);

      final sharedFile = container.read(latestSharedFileProvider);
      expect(sharedFile, isNotNull);
      expect(sharedFile!.path, 'initial.jpg');
    });
  });
}
