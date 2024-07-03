part of 'friends_bloc.dart';

@immutable
sealed class FriendsEvent {}

class GetFriends extends FriendsEvent {}
class GetFriendsRequestsEvent extends FriendsEvent {
  String uid;
  String groupId;
  GetFriendsRequestsEvent({required this.uid, required this.groupId});
}
class AcceptFriendRequestEvent extends FriendsEvent {
  final String friendId;
  AcceptFriendRequestEvent({required this.friendId});
}
