import 'package:rich_chat_copilot/lib/src/core/resources/shared_preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetLanguageUseCase {
  final SharedPreferences sharedPreferences;

  SetLanguageUseCase(this.sharedPreferences);

  Future<bool> call(String language) async {
    return await sharedPreferences.setString(
        SharedPreferenceKeys.language, language);
  }
}

