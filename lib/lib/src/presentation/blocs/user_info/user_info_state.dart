part of 'user_info_bloc.dart';

@immutable
sealed class UserInfoState {}

final class UserInfoInitial extends UserInfoState {}
final class SelectImageState extends UserInfoState {
  final File image;
  SelectImageState({required this.image});
}
final class ShowImageState extends UserInfoState {
  final File image;
  ShowImageState({required this.image});
}
final class ErrorState extends UserInfoState {
  final String error;
  ErrorState({required this.error});
}
final class LoadingState extends UserInfoState {}
final class SuccessState extends UserInfoState {}
