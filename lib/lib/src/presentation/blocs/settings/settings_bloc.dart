import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_language_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_theme_use_case.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SetThemeUseCase _setThemeUseCase;
  final SetLanguageUseCase _setLanguageUseCase;

  SettingsBloc(
    this._setThemeUseCase,
    this._setLanguageUseCase,
  ) : super(SettingsInitial()) {
    on<ChangeLanguageEvent>(_onChangeLanguageEvent);
    on<ChangeThemeEvent>(_onChangeThemeEvent);
  }

  FutureOr<void> _onChangeLanguageEvent(
      ChangeLanguageEvent event, Emitter<SettingsState> emit) async {
    await _setLanguageUseCase(event.language);
    emit(ChangeLanguageSuccess());
  }

  FutureOr<void> _onChangeThemeEvent(
      ChangeThemeEvent event, Emitter<SettingsState> emit) async {
    await _setThemeUseCase(
        event.isDarkTheme ? Constants.dark : Constants.light);
    emit(ChangeThemeSuccess());
  }
}
