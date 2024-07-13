part of 'group_bloc.dart';

@immutable
sealed class GroupEvent {}
class ClearGroupEvent extends GroupEvent {}
class SendRequestToJoinGroupEvent extends GroupEvent {
  final String uid;
  final String groupName;
  final String groupImage;
  final String groupId;
  SendRequestToJoinGroupEvent({
    required this.uid,
    required this.groupName,
    required this.groupImage
    ,required this.groupId,
  });
}
class AcceptRequestToJoinGroupEvent extends GroupEvent {
  final String groupId;
  final String uid;
  AcceptRequestToJoinGroupEvent({
    required this.groupId,
    required this.uid
  });
}
class ShowImageEvent extends GroupEvent {
  final File image;
  final String groupId;
  ShowImageEvent({
    required this.image,
    required this.groupId,
  });
}
