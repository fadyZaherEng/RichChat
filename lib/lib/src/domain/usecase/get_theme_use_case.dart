import 'package:rich_chat_copilot/lib/src/core/resources/shared_preferences_keys.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetThemeUseCase {
  final SharedPreferences sharedPreferences;

  GetThemeUseCase(this.sharedPreferences);

  bool call() {
    return (sharedPreferences.getString(SharedPreferenceKeys.theme) ??Constants.light) == Constants.dark;
  }
}
