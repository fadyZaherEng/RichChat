part of 'user_info_bloc.dart';

@immutable
sealed class UserInfoEvent {}

class SelectImageEvent extends UserInfoEvent {
  final File image;

  SelectImageEvent(this.image);
}

class ShowImageEvent extends UserInfoEvent {
  final File image;

  ShowImageEvent(this.image);
}

class ContinueEvent extends UserInfoEvent {
   UserModel userModel;
  final File? image;

  ContinueEvent({
    this.image,
    required this.userModel,
  });
}
