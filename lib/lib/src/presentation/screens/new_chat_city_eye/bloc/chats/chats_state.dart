part of 'chats_bloc.dart';

@immutable
sealed class ChatsState {}

final class ChatsInitial extends ChatsState {}

final class GetUserChatsLoading extends ChatsState {}

final class GetUserChatsSuccess extends ChatsState {
  final List<User> users;

  GetUserChatsSuccess({required this.users});
}

final class GetUserChatsError extends ChatsState {
  final String message;

  GetUserChatsError({required this.message});
}

final class GetCurrentUserChatsLoading extends ChatsState {}

final class GetCurrentUserChatsSuccess extends ChatsState {
  final User user;

  GetCurrentUserChatsSuccess({required this.user});
}

final class GetCurrentUserChatsError extends ChatsState {
  final String message;

  GetCurrentUserChatsError({required this.message});
}

//send text message
final class SendTextMessageLoading extends ChatsState {}

final class SendTextMessageSuccess extends ChatsState {}

final class SendTextMessageError extends ChatsState {
  final String message;

  SendTextMessageError({required this.message});
}

final class SetMassageReplyState extends ChatsState {
  final MassageReply? massageReply;

  SetMassageReplyState({required this.massageReply});
}

//set massage as seen
final class SetMassageAsSeenLoading extends ChatsState {}

final class SetMassageAsSeenSuccess extends ChatsState {}

final class SetMassageAsSeenError extends ChatsState {
  final String message;

  SetMassageAsSeenError({required this.message});
}

//send file massage
final class SendFileMessageLoading extends ChatsState {}

final class SendFileMessageSuccess extends ChatsState {}

final class SendFileMessageError extends ChatsState {
  final String message;

  SendFileMessageError({required this.message});
}

//select image state
final class SelectImageState extends ChatsState {
  final File file;

  SelectImageState({required this.file});
}

//select video from galley
final class SelectVideoFromGalleryState extends ChatsState {
  final File file;

  SelectVideoFromGalleryState({required this.file});
}

//reaction
class SendReactionsToMassageLoading extends ChatsState {}

class SendReactionsToMassageSuccess extends ChatsState {}

class SendReactionsToMassageError extends ChatsState {
  final String message;

  SendReactionsToMassageError({required this.message});
}

//delete massage
class DeleteMassageLoading extends ChatsState {}

class DeleteMassageSuccess extends ChatsState {
  final String massage;

  DeleteMassageSuccess({required this.massage});
}

class DeleteMassageError extends ChatsState {
  final String message;

  DeleteMassageError({required this.message});
}

class SearchQueryState extends ChatsState {}
