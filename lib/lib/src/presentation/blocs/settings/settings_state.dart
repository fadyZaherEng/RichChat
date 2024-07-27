part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {}

final class SettingsInitial extends SettingsState {}

final class SettingsLoading extends SettingsState {}
final class ChangeLanguageSuccess extends SettingsState {}
final class ChangeThemeSuccess extends SettingsState {}
