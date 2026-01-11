import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';
import 'package:mealtrack/features/sharing/provider/sharing_provider.dart';

// Manual Fake
class FakeFirestoreService extends Fake implements FirestoreService {
  bool shouldThrow = false;
  String generatedCode = '123456';
  String? joinedCode;

  @override
  Future<String> generateInviteCode() async {
    if (shouldThrow) throw Exception('Generate Error');
    return generatedCode;
  }

  @override
  Future<void> joinHousehold(String code) async {
    if (shouldThrow) throw Exception('Join Error');
    joinedCode = code;
  }
}

void main() {
  late FakeFirestoreService fakeFirestoreService;

  setUp(() {
    fakeFirestoreService = FakeFirestoreService();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        firestoreServiceProvider.overrideWithValue(fakeFirestoreService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SharingViewModel', () {
    test('initial state is AsyncData(null)', () {
      final container = makeContainer();
      final state = container.read(sharingViewModelProvider);

      expect(state, const AsyncData<String?>(null));
    });

    group('generateCode', () {
      test('sets state to generated code on success', () async {
        final container = makeContainer();

        // Trigger
        await container.read(sharingViewModelProvider.notifier).generateCode();

        // Verify state matches the generated code
        final state = container.read(sharingViewModelProvider);
        expect(state.value, '123456');
        expect(state, isA<AsyncData>());
      });

      test('sets state to AsyncError on failure', () async {
        final container = makeContainer();
        fakeFirestoreService.shouldThrow = true;

        await container.read(sharingViewModelProvider.notifier).generateCode();

        final state = container.read(sharingViewModelProvider);
        expect(state, isA<AsyncError>());
        expect(state.error.toString(), contains('Generate Error'));
      });
    });

    group('joinHousehold', () {
      test('sets state to "JOINED" on success and calls service', () async {
        final container = makeContainer();
        const codeToJoin = '654321';

        await container
            .read(sharingViewModelProvider.notifier)
            .joinHousehold(codeToJoin);

        final state = container.read(sharingViewModelProvider);
        expect(state.value, 'JOINED');
        expect(state, isA<AsyncData>());
        expect(fakeFirestoreService.joinedCode, codeToJoin);
      });

      test('sets state to AsyncError on failure', () async {
        final container = makeContainer();
        fakeFirestoreService.shouldThrow = true;

        await container
            .read(sharingViewModelProvider.notifier)
            .joinHousehold('111222');

        final state = container.read(sharingViewModelProvider);
        expect(state, isA<AsyncError>());
        expect(state.error.toString(), contains('Join Error'));
      });
    });
  });
}
