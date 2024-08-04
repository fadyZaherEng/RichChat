import 'package:city_eye/generated/l10n.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:city_eye/src/domain/entities/chat/massage_reply.dart';
import 'package:city_eye/src/domain/entities/sign_in/user.dart';
import 'package:city_eye/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:city_eye/src/presentation/screens/chats/skeleton/chats_skeleton.dart';
import 'package:city_eye/src/presentation/screens/chats/utils/show_reactions_dialog.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/massage_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/my_massage_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/receiver_massage_widget.dart';
import 'package:city_eye/src/presentation/widgets/build_date_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:skeletons/skeletons.dart';

class ChatsListMassagesWidget extends StatefulWidget {
  final Stream<List<Massage>> massagesStream;
  final ScrollController massagesScrollController;
  final User currentUser;
  final void Function(MassageReply massageReply) onRightSwipe;
  final void Function(String, Massage) onEmojiSelected;
  final void Function(String, Massage) onContextMenuSelected;
  final void Function(Massage) showEmojiKeyword;
  final void Function() setMassageReplyNull;
  final int subscriberId;
  final int compoundId;

  const ChatsListMassagesWidget({
    super.key,
    required this.massagesStream,
    required this.massagesScrollController,
    required this.currentUser,
    required this.onRightSwipe,
    required this.onEmojiSelected,
    required this.onContextMenuSelected,
    required this.showEmojiKeyword,
    required this.setMassageReplyNull,
    required this.subscriberId,
    required this.compoundId,
  });

  @override
  State<ChatsListMassagesWidget> createState() =>
      _ChatsListMassagesWidgetState();
}

class _ChatsListMassagesWidgetState extends State<ChatsListMassagesWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<List<Massage>>(
          stream: widget.massagesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("Get massages error: ${snapshot.error}");
              return const ChatsSkeleton();
            }
            if (!snapshot.hasData ||
                snapshot.data != null && snapshot.data!.isEmpty) {
              if (snapshot.data != null && snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    S.of(context).startConversation,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ColorSchemes.black,
                        ),
                  ),
                );
              }
              return const ChatsSkeleton();
            }
            if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  S.of(context).startConversation,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ColorSchemes.black,
                      ),
                ),
              );
            }
            if (snapshot.hasData) {
              final massages = snapshot.data ?? [];
              return GroupedListView<Massage, DateTime>(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                reverse: true,
                elements: massages,
                controller: widget.massagesScrollController,
                groupBy: (Massage massage) => DateTime(
                  massage.timeSent.year,
                  massage.timeSent.month,
                  massage.timeSent.day,
                ),
                groupHeaderBuilder: (Massage massage) => buildDateWidget(
                  context: context,
                  dateTime: massage.timeSent,
                ),
                useStickyGroupSeparators: true,
                floatingHeader: true,
                order: GroupedListOrder.DESC,
                itemBuilder: (BuildContext context, Massage massage) {
                  //set massage as seen in fireStore
                  BlocProvider.of<ChatsBloc>(context).setMassageAsSeen(
                    senderId: widget.currentUser.userInformation.id,
                    massageId: massage.messageId,
                    subscriberId: widget.subscriberId,
                    compoundId: widget.compoundId,
                    isSeenByList: massage.isSeenBy,
                  );
                  bool isMe =
                      massage.senderId == widget.currentUser.userInformation.id;
                  //check if massage delete by current user
                  final deletedByCurrentUser = massage.isDeletedBy
                          .contains(widget.currentUser.userInformation.id) ||
                      massage.isDeletedBy.contains(-1);

                  return deletedByCurrentUser
                      ? _deletedMassageWidget(
                          context: context,
                          isMe: isMe,
                          massage: massage,
                        )
                      : GestureDetector(
                          onLongPress: () async {
                            //TODO: Chat Reactions By Myself
                            if (deletedByCurrentUser) return;
                            _showReactionDialog(
                              isMe: isMe,
                              massage: massage,
                              context: context,
                            );
                            //TODO: Chat Reactions By Package
                            //using by package flutter_chat_reaction
                            // _showReactionDialogByPackage(
                            //   isMe: isMe,
                            //   massage: massage,
                            //   context: context,
                            // );
                          },
                          child: MessageWidget(
                            message: massage,
                            isMe: isMe,
                            uid: widget.currentUser.userInformation.id,
                            onRightSwipe: () {
                              final massageReply = MassageReply(
                                massage: massage.massage,
                                senderName: massage.senderName,
                                senderId: massage.senderId.toString(),
                                senderImage: massage.senderImage,
                                massageType: massage.massageType,
                                isMe: isMe,
                              );
                              widget.onRightSwipe(massageReply);
                            },
                            setMassageReplyNull: () {
                              widget.setMassageReplyNull();
                            },
                          ),
                        );
                },
                itemComparator: (massage1, massage2) =>
                    massage1.timeSent.compareTo(massage2.timeSent),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  //reactions dialog
  Future<void> _showReactionDialog({
    required bool isMe,
    required massage,
    required BuildContext context,
  }) async {
    showReactionsDialog(
      context: context,
      massage: massage,
      isMe: isMe,
      currentUserId: widget.currentUser.userInformation.id,
      onContextMenuSelected: (emoji, massage) {
        widget.onContextMenuSelected(emoji, massage);
      },
      onEmojiSelected: (emoji, massage) {
        widget.onEmojiSelected(emoji, massage);
      },
      setMassageReplyNull: () {
        widget.setMassageReplyNull();
      },
    );
  }

  void _showReactionDialogByPackage({
    required bool isMe,
    required Massage massage,
    required BuildContext context,
  }) {
    Navigator.push(
      context,
      HeroDialogRoute(
        builder: (context) => ReactionsDialogWidget(
          id: massage.messageId,
          messageWidget: isMe
              ? MyMassageWidget(
                  massage: massage,
                  isReplying: massage.repliedTo.isNotEmpty,
                  uid: widget.currentUser.userInformation.id,
                  setMassageReplyNull: () {
                    widget.setMassageReplyNull();
                  },
                )
              : ReceiverMassageWidget(
                  massage: massage,
                  isReplying: massage.repliedTo.isNotEmpty,
                  setMassageReplyNull: () {
                    widget.setMassageReplyNull();
                  },
                ),
          onReactionTap: (reaction) {
            widget.onEmojiSelected(reaction, massage);
          },
          onContextMenuTap: (contextMenu) {
            widget.onContextMenuSelected(contextMenu.label, massage);
          },
          widgetAlignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          // menuItems: const[
          //   MenuItem(label: Constants.reply, icon: Icons.reply),
          //   MenuItem(label: Constants.copy, icon: Icons.copy),
          //   MenuItem(label: "forward", icon: Icons.forward),
          //   MenuItem(label: Constants.delete, icon: Icons.delete,isDestuctive: true),
          // ],
        ),
      ),
    );
  }

  Widget _deletedMassageWidget({
    required BuildContext context,
    required bool isMe,
    required Massage massage,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 5, top: 5),
              child: InkWell(
                onTap: () {},
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorSchemes.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      massage.senderImage,
                      fit: BoxFit.fill,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SvgPicture.asset(
                            ImagePaths.avatar,
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SkeletonLine(
                            style: SkeletonLineStyle(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft:
                    isMe ? const Radius.circular(15) : const Radius.circular(0),
                bottomRight:
                    isMe ? const Radius.circular(0) : const Radius.circular(15),
              ),
            ),
            color: ColorSchemes.lightGray,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    S.of(context).canceledSendingTheMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: ColorSchemes.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
