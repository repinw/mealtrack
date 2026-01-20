class SharingException implements Exception {
  final String message;
  SharingException(this.message);
  @override
  String toString() => message;
}

class InviteExpiredException extends SharingException {
  InviteExpiredException() : super('Code Expired');
}

class SelfJoinException extends SharingException {
  SelfJoinException() : super('Cannot Join Own Household');
}

class InvalidInviteCodeException extends SharingException {
  InvalidInviteCodeException() : super('Invalid Code');
}
