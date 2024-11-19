import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clipboard/clipboard.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/password_generator_service.dart';

final passwordLengthProvider = StateProvider<int>((ref) => 8);
final includeLowerCaseProvider = StateProvider<bool>((ref) => true);
final includeUpperCaseProvider = StateProvider<bool>((ref) => true);
final includeSpecialCharsProvider = StateProvider<bool>((ref) => true);
final includeNumbersProvider = StateProvider<bool>((ref) => true);
final generatedPasswordProvider = StateProvider<String>((ref) => '');
final passwordValidationMessageProvider = StateProvider<String>((ref) => '');

class PasswordGeneratorScreen extends ConsumerWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordLength = ref.watch(passwordLengthProvider);
    final includeLowerCase = ref.watch(includeLowerCaseProvider);
    final includeUpperCase = ref.watch(includeUpperCaseProvider);
    final includeSpecialChars = ref.watch(includeSpecialCharsProvider);
    final includeNumbers = ref.watch(includeNumbersProvider);
    final generatedPassword = ref.watch(generatedPasswordProvider);
    final validationMessage = ref.watch(passwordValidationMessageProvider);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Set Password Criteria',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              // Password Length Input
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Password Length',
                  hintText: 'Enter length (e.g., 8)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  ref.read(passwordLengthProvider.notifier).state =
                      int.tryParse(value) ?? 8;
                },
              ),
              const SizedBox(height: 10),
              // Character Options
              _buildCheckbox(
                ref: ref,
                label: 'Include Lowercase Letters',
                provider: includeLowerCaseProvider,
              ),
              _buildCheckbox(
                ref: ref,
                label: 'Include Uppercase Letters',
                provider: includeUpperCaseProvider,
              ),
              _buildCheckbox(
                ref: ref,
                label: 'Include Special Characters',
                provider: includeSpecialCharsProvider,
              ),
              _buildCheckbox(
                ref: ref,
                label: 'Include Numbers',
                provider: includeNumbersProvider,
              ),
              const SizedBox(height: 10),
              // Validation Message
              if (validationMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    validationMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (passwordLength <= 0) {
                        ref
                            .read(passwordValidationMessageProvider.notifier)
                            .state = 'Please enter a valid password length!';
                        return;
                      }

                      final password =
                          PasswordGeneratorService().generatePassword(
                        length: passwordLength,
                        includeLowerCase: includeLowerCase,
                        includeUpperCase: includeUpperCase,
                        includeSpecialChars: includeSpecialChars,
                        includeNumbers: includeNumbers,
                      );

                      ref.read(generatedPasswordProvider.notifier).state =
                          password;
                      saveSettings(
                        passwordLength,
                        includeLowerCase,
                        includeUpperCase,
                        includeSpecialChars,
                        includeNumbers,
                      );

                      // Validate password generation
                      final validationMsg = password.isEmpty
                          ? 'Password generation failed! Please check your criteria.'
                          : '';
                      ref
                          .read(passwordValidationMessageProvider.notifier)
                          .state = validationMsg;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Stylish button color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text(
                      'Generate',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(passwordLengthProvider.notifier).state = 8;
                      ref.read(includeLowerCaseProvider.notifier).state = true;
                      ref.read(includeUpperCaseProvider.notifier).state = true;
                      ref.read(includeSpecialCharsProvider.notifier).state =
                          true;
                      ref.read(includeNumbersProvider.notifier).state = true;
                      ref.read(generatedPasswordProvider.notifier).state = '';
                      ref
                          .read(passwordValidationMessageProvider.notifier)
                          .state = '';
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Reset button color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Generated Password Section
              if (generatedPassword.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Generated Password:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    AutoSizeText(
                      generatedPassword,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                      minFontSize: 16,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        FlutterClipboard.copy(generatedPassword).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password copied to clipboard!')),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.deepPurpleAccent, // Copy button color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text(
                        'Copy Password',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build Checkboxes

  Widget _buildCheckbox({
    required WidgetRef ref,
    required String label,
    required StateProvider<bool> provider,
  }) {
    return CheckboxListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      value: ref.watch(provider),
      onChanged: (value) {
        ref.read(provider.notifier).state = value!;
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  // Save settings to SharedPreferences
  Future<void> saveSettings(int length, bool lowerCase, bool upperCase,
      bool specialChars, bool numbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('passwordLength', length);
    await prefs.setBool('includeLowerCase', lowerCase);
    await prefs.setBool('includeUpperCase', upperCase);
    await prefs.setBool('includeSpecialChars', specialChars);
    await prefs.setBool('includeNumbers', numbers);
  }
}
