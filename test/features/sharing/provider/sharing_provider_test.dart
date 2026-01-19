import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/sharing/data/household_repository.dart';
import 'package:mealtrack/features/sharing/provider/sharing_provider.dart';

class FakeHouseholdRepository extends Fake implements HouseholdRepository {
  String? errorToThrow;
  String generatedCode = '123456';
  String? joinedCode;

  @override
  Future<String> generateInviteCode() async {
    if (errorToThrow != null) throw Exception(errorToThrow);
    return generatedCode;
  }

  @override
  Future<void> joinHousehold(String code) async {
    if (errorToThrow != null) throw Exception(errorToThrow);
    joinedCode = code;
  }
}

void main() {
  late FakeHouseholdRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeHouseholdRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        householdRepositoryProvider.overrideWithValue(fakeRepository),
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
        fakeRepository.errorToThrow = 'Generate Error';

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
        expect(fakeRepository.joinedCode, codeToJoin);
      });

      test('sets state to AsyncError on failure', () async {
        final container = makeContainer();
        fakeRepository.errorToThrow = 'Join Error';

        await container
            .read(sharingViewModelProvider.notifier)
            .joinHousehold('111222');

        final state = container.read(sharingViewModelProvider);
        expect(state, isA<AsyncError>());
        expect(state.error.toString(), contains('Join Error'));
      });

      test(
        'sets state to AsyncError with "Invalid Code" for UI handling',
        () async {
          final container = makeContainer();
          fakeRepository.errorToThrow = 'Invalid Code';

          await container
              .read(sharingViewModelProvider.notifier)
              .joinHousehold('000000');

          final state = container.read(sharingViewModelProvider);
          expect(state, isA<AsyncError>());
          expect(state.error.toString(), contains('Invalid Code'));
        },
      );
    });
  });
}
