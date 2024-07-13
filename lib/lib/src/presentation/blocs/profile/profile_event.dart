part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}
class SendFriendRequestEvent extends ProfileEvent {
  final String friendId;
  SendFriendRequestEvent(this.friendId);
}
class CancelFriendRequestEvent extends ProfileEvent {
  final String friendId;
  CancelFriendRequestEvent(this.friendId);
}
class AcceptFriendRequestEvent extends ProfileEvent {
  final String friendId;
  AcceptFriendRequestEvent(this.friendId);
}
class UnfriendEvent extends ProfileEvent {
  final String friendId;
  UnfriendEvent(this.friendId);
}
class ShowImageEvent extends ProfileEvent {
  final File file;
  ShowImageEvent(this.file);
}