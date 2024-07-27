import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_language_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_theme_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_theme_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_language_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_theme_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_user_use_case.dart';

Future<void> initializeUseCaseDependencies() async {
  injector.registerFactory<SetLanguageUseCase>(
      () => SetLanguageUseCase(injector()));

  injector.registerFactory<GetLanguageUseCase>(() => GetLanguageUseCase(injector()));
  injector.registerFactory<GetThemeUseCase>(() => GetThemeUseCase(injector()));
  injector.registerFactory<SetThemeUseCase>(() => SetThemeUseCase(injector()));
  injector.registerFactory<SetUserUseCase>(() => SetUserUseCase(injector()));
  injector.registerFactory<GetUserUseCase>(() => GetUserUseCase(injector()));
}
