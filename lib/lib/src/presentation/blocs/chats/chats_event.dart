part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

class GetAllUsersEvent extends ChatsEvent {}

class GetCurrentUserEvent extends ChatsEvent {
  final String uid;

  GetCurrentUserEvent({required this.uid});
}

class SendTextMessageEvent extends ChatsEvent {
  final UserModel sender;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String message;
  final MassageType massageType;
  final String groupId;
  final BuildContext context;

  SendTextMessageEvent({
    required this.sender,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.message,
    required this.massageType,
    required this.groupId,
    required this.context,
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
  final UserModel sender;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final File file;
  final MassageType massageType;
  final String groupId;
  final BuildContext context;

  SendFileMessageEvent({
    required this.sender,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.file,
    required this.massageType,
    required this.groupId,
    required this.context,
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
  final String receiverId;
  final String reaction;
  final bool groupId;

  SelectReactionEvent({
    required this.massageId,
    required this.senderId,
    required this.receiverId,
    required this.reaction,
    required this.groupId,
  });
}

//delete massage
class DeleteMassageEvent extends ChatsEvent {
  final String currentUserId;
  final String contactUID;
  final String messageId;
  final String messageType;
  final bool isGroupChat;
  final bool deleteForEveryone;

  DeleteMassageEvent({
    required this.currentUserId,
    required this.contactUID,
    required this.messageId,
    required this.messageType,
    required this.isGroupChat,
    required this.deleteForEveryone,
  });
}
