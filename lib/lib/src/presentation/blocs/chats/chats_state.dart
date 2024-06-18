part of 'chats_bloc.dart';

@immutable
sealed class ChatsState {}

final class ChatsInitial extends ChatsState {}
final class GetUserChatsLoading extends ChatsState {}
final class GetUserChatsSuccess extends ChatsState {
  final List<UserModel> users;
  GetUserChatsSuccess({required this.users});
}
final class GetUserChatsError extends ChatsState {
  final String message;
  GetUserChatsError({required this.message});
}
final class GetCurrentUserChatsLoading extends ChatsState {}
final class GetCurrentUserChatsSuccess extends ChatsState {
  final UserModel user;
  GetCurrentUserChatsSuccess({required this.user});
}
final class GetCurrentUserChatsError extends ChatsState {
  final String message;
  GetCurrentUserChatsError({required this.message});
}