part of 'friends_bloc.dart';

@immutable
sealed class FriendsState {}

final class FriendsInitial extends FriendsState {}

final class GetFriendsLoading extends FriendsState {}
final class GetFriendsSuccess extends FriendsState {
  final List<UserModel> friends;
  GetFriendsSuccess({required this.friends});
}

final class GetFriendsError extends FriendsState {
  final String error;
  GetFriendsError({required this.error});
}


final class FriendsRequestsInitial extends FriendsState {}

final class GetFriendsRequestsLoading extends FriendsState {}

final class GetFriendsRequestsError extends FriendsState {
  final String message;

  GetFriendsRequestsError({required this.message});
}

final class GetFriendsRequestsSuccess extends FriendsState {
  final List<UserModel> friendsRequests;

  GetFriendsRequestsSuccess({required this.friendsRequests});
}
final class AcceptFriendRequestsLoading extends FriendsState {}

final class AcceptFriendRequestsError extends FriendsState {
  final String message;

  AcceptFriendRequestsError({required this.message});
}

final class AcceptFriendRequestsSuccess extends FriendsState {}

