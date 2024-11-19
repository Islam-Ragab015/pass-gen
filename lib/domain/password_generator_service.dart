import 'dart:math';
import 'package:pass_gen/data/password_rules.dart';

class PasswordGeneratorService {
  final Random _random = Random();

  String generatePassword({
    required int length,
    required bool includeLowerCase,
    required bool includeUpperCase,
    required bool includeSpecialChars,
    required bool includeNumbers,
  }) {
    // Validate the password length
    if (!PasswordRules.isLengthValid(length)) {
      return 'length must be between ${PasswordRules.minLength} and ${PasswordRules.maxLength}';
    }

    // Validate if at least one character set is selected
    if (!PasswordRules.isAtLeastOneCharacterSetSelected(
      includeLowerCase: includeLowerCase,
      includeUpperCase: includeUpperCase,
      includeSpecialChars: includeSpecialChars,
      includeNumbers: includeNumbers,
    )) {
      return 'Please select at least one character set!';
    }

    // Build the character set dynamically and avoid duplicates
    String combinedCharSet = '';
    if (includeLowerCase) combinedCharSet += PasswordRules.lowerCaseChars;
    if (includeUpperCase) combinedCharSet += PasswordRules.upperCaseChars;
    if (includeSpecialChars) combinedCharSet += PasswordRules.specialChars;
    if (includeNumbers) combinedCharSet += PasswordRules.numbers;

    // Generate the password by picking random characters from the combined set
    return List.generate(length, (_) {
      return combinedCharSet[_random.nextInt(combinedCharSet.length)];
    }).join('');
  }
}
