part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

class GetAllUsersEvent extends ChatsEvent {}

class GetCurrentUserEvent extends ChatsEvent {
  final String uid;

  GetCurrentUserEvent({required this.uid});
}

class SendTextMessageEvent extends ChatsEvent {
  final User sender;
  final int receiverId;
  final int compoundId;//replace with group id
  final int subscriberId;
  final String message;
  final MassageType massageType;

  SendTextMessageEvent({
    required this.sender,
    required this.receiverId,
    required this.compoundId,
    required this.subscriberId,
    required this.message,
    required this.massageType,
  });
}

class SetMassageAsSentEvent extends ChatsEvent {
  final String messageId;
  final String receiverId;
  final String senderId;
  final String groupId;

  SetMassageAsSentEvent({
    required this.messageId,
    required this.receiverId,
    required this.senderId,
    required this.groupId,
  });
}

class SendFileMessageEvent extends ChatsEvent {
  final User sender;
  final int compoundId;
  final int subscriberId;
  final String compoundName;
  final String compoundImage;
  final File file;
  final MassageType massageType;

  SendFileMessageEvent({
    required this.sender,
    required this.file,
    required this.subscriberId,
    required this.massageType,
    required this.compoundId,
    required this.compoundName,
    required this.compoundImage,
  });
}

class SelectImageEvent extends ChatsEvent {
  final File file;

  SelectImageEvent(this.file);
}

class ShowImageEvent extends ChatsEvent {
  final File file;

  ShowImageEvent(this.file);
}

//select video from galley
class SelectVideoFromGalleryEvent extends ChatsEvent {
  final File file;

  SelectVideoFromGalleryEvent(this.file);
}

//reactions
class SelectReactionEvent extends ChatsEvent {
  final String massageId;
  final String senderId;
  final String reaction;
  final int compoundId;
  final int subscriberId;

  SelectReactionEvent({
    required this.massageId,
    required this.senderId,
    required this.reaction,
    required this.compoundId,
    required this.subscriberId,
  });
}

//delete massage
class DeleteMassageEvent extends ChatsEvent {
  final int currentUserId;
  final String messageId;
  final String messageType;
  final int compoundId;
  final int subscriberId;
  final bool deleteForEveryone;

  DeleteMassageEvent({
    required this.currentUserId,
    required this.messageId,
    required this.messageType,
    required this.deleteForEveryone,
    required this.compoundId,
    required this.subscriberId,
  });
}
