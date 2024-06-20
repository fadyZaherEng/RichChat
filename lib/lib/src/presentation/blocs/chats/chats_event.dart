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

  SendTextMessageEvent({
    required this.sender,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.message,
    required this.massageType,
    required this.groupId,
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

  SendFileMessageEvent({
    required this.sender,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.file,
    required this.massageType,
    required this.groupId,
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
