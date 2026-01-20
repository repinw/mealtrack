const Set<String> networkErrorCodes = {
  'network-request-failed',
  'unavailable',
  'deadline-exceeded',
};

bool isNetworkError(String code) => networkErrorCodes.contains(code);
