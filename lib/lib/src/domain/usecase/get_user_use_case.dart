import 'dart:convert';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetUserUseCase {
  final SharedPreferences sharedPreferences;

  GetUserUseCase(this.sharedPreferences);

  UserModel call() {
    return sharedPreferences.getString(Constants.user) == null
        ? UserModel()
        : UserModel.fromJson(
            jsonDecode(sharedPreferences.getString(Constants.user) ?? ""),
          );
  }
}
