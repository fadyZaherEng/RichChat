part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

// Send Friend Request
final class SendFriendRequestLoading extends ProfileState {}

final class SendFriendRequestSuccess extends ProfileState {}

final class SendFriendRequestFailed extends ProfileState {}

// Cancel Friend Request
final class CancelFriendRequestLoading extends ProfileState {}

final class CancelFriendRequestSuccess extends ProfileState {}

final class CancelFriendRequestFailed extends ProfileState {}

// Accept Friend Request
final class AcceptFriendRequestLoading extends ProfileState {}

final class AcceptFriendRequestSuccess extends ProfileState {}

final class AcceptFriendRequestFailed extends ProfileState {}

//unFriend
final class UnFriendLoading extends ProfileState {}

final class UnFriendSuccess extends ProfileState {}

final class UnFriendFailed extends ProfileState {}

final class ShowImageState extends ProfileState {
  final File imageUrl;

  ShowImageState({
    required this.imageUrl,
  });
}
