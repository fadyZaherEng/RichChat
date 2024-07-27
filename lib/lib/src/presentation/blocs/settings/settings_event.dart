part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {}

class ChangeThemeEvent extends SettingsEvent {
  final bool isDarkTheme;
  ChangeThemeEvent({required this.isDarkTheme});
}

class ChangeLanguageEvent extends SettingsEvent {
  final String language;
  ChangeLanguageEvent({required this.language});
}

