import 'dart:convert';

import 'package:rich_chat_copilot/lib/src/core/resources/shared_preferences_keys.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetUserUseCase {
  final SharedPreferences sharedPreferences;

  SetUserUseCase(this.sharedPreferences);

  Future<bool> call(UserModel userModel) async {
    return await sharedPreferences.setString(
        SharedPreferenceKeys.user, jsonEncode(userModel.toJson()));
  }
}
