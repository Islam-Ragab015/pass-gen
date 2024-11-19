class PasswordRules {
  static const int minLength = 8;
  static const int maxLength = 20;

  static const String lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String numbers = '0123456789';
  static const String specialChars = '!@#\$%^&*()_-+=<>?';

  // Check if the password length is valid
  static bool isLengthValid(int length) {
    return length >= minLength && length <= maxLength;
  }

  // Ensure that at least one character set is selected
  static bool isAtLeastOneCharacterSetSelected({
    required bool includeLowerCase,
    required bool includeUpperCase,
    required bool includeSpecialChars,
    required bool includeNumbers,
  }) {
    return includeLowerCase ||
        includeUpperCase ||
        includeSpecialChars ||
        includeNumbers;
  }
}
