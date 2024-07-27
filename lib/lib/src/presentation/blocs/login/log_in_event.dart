part of 'log_in_bloc.dart';

@immutable
sealed class LogInEvent {}
class LogInOnChangePhoneNumberEvent extends LogInEvent{
 final String value;
 LogInOnChangePhoneNumberEvent(this.value);
}
class LogInOnChangeCountryEvent extends LogInEvent{
  final Country country;
  LogInOnChangeCountryEvent(this.country);
}
class LogInOnLogInEvent extends LogInEvent{
  final String phoneNumber;
  final BuildContext context;
  LogInOnLogInEvent(this.phoneNumber, this.context);
}
