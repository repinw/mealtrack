import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/extensions/user_extension.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

void main() {
  late MockUser mockUser;
  late MockUserInfo mockUserInfo;

  setUp(() {
    mockUser = MockUser();
    mockUserInfo = MockUserInfo();
  });

  group('UserExtension', () {
    test(
      'updateDisplayNameFromProvider does nothing if displayName is set',
      () async {
        when(() => mockUser.displayName).thenReturn('Existing Name');

        await mockUser.updateDisplayNameFromProvider();

        verifyNever(() => mockUser.updateDisplayName(any()));
        verifyNever(() => mockUser.reload());
      },
    );

    test(
      'updateDisplayNameFromProvider updates name if null and provider has name',
      () async {
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUserInfo.displayName).thenReturn('Provider Name');
        when(() => mockUser.providerData).thenReturn([mockUserInfo]);
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
        when(() => mockUser.reload()).thenAnswer((_) async {});

        await mockUser.updateDisplayNameFromProvider();

        verify(() => mockUser.updateDisplayName('Provider Name')).called(1);
        verify(() => mockUser.reload()).called(1);
      },
    );

    test(
      'updateDisplayNameFromProvider updates name if empty and provider has name',
      () async {
        when(() => mockUser.displayName).thenReturn('');
        when(() => mockUserInfo.displayName).thenReturn('Provider Name');
        when(() => mockUser.providerData).thenReturn([mockUserInfo]);
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
        when(() => mockUser.reload()).thenAnswer((_) async {});

        await mockUser.updateDisplayNameFromProvider();

        verify(() => mockUser.updateDisplayName('Provider Name')).called(1);
        verify(() => mockUser.reload()).called(1);
      },
    );

    test(
      'updateDisplayNameFromProvider does nothing if provider name is null',
      () async {
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUserInfo.displayName).thenReturn(null);
        when(() => mockUser.providerData).thenReturn([mockUserInfo]);

        await mockUser.updateDisplayNameFromProvider();

        verifyNever(() => mockUser.updateDisplayName(any()));
      },
    );

    test(
      'updateDisplayNameFromProvider does nothing if provider name is empty',
      () async {
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUserInfo.displayName).thenReturn('');
        when(() => mockUser.providerData).thenReturn([mockUserInfo]);

        await mockUser.updateDisplayNameFromProvider();

        verifyNever(() => mockUser.updateDisplayName(any()));
      },
    );
  });
}
