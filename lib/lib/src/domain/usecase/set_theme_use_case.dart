import 'package:rich_chat_copilot/lib/src/core/resources/shared_preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetThemeUseCase {
  final SharedPreferences sharedPreferences;

  SetThemeUseCase(this.sharedPreferences);

  Future<bool> call(String theme) async {
    return await sharedPreferences.setString(
        SharedPreferenceKeys.theme, theme);
  }
}
