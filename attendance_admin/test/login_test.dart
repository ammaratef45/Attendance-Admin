
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:test_core/test_core.dart';

class MockUser extends Mock implements FirebaseUser{}

main() {
  group('handle user', () {
    test('test user is null', () {
      final user =MockUser();
      expect(user, isInstanceOf<FirebaseUser>());
    });
  });
}