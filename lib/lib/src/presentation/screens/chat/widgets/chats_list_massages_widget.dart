import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage_reply.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/utils/show_reactions_dialog.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/massage_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/stacked_reactions_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/build_date_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/cricle_loading_widget.dart';

class ChatsListMassagesWidget extends StatefulWidget {
  final Stream<List<Massage>> massagesStream;
  final ScrollController massagesScrollController;
  final UserModel currentUser;
  final String friendId;
  final void Function(MassageReply massageReply) onRightSwipe;
  final void Function(String, Massage) onEmojiSelected;
  final void Function(String, Massage) onContextMenuSelected;
  final void Function(Massage) showEmojiKeyword;
  final String groupId;

  const ChatsListMassagesWidget({
    super.key,
    required this.massagesStream,
    required this.massagesScrollController,
    required this.currentUser,
    required this.onRightSwipe,
    required this.friendId,
    required this.onEmojiSelected,
    required this.onContextMenuSelected,
    required this.showEmojiKeyword,
    required this.groupId,
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
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Massage>>(
          stream: widget.massagesStream,
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const CircleLoadingWidget();
            // }
            if (snapshot.hasError) {
              print("""Error: ${snapshot.error}""");
              return Center(
                child: Text(
                  S.of(context).somethingWentWrong,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorSchemes.gray,
                  ),
                ),
              );
            }
            if (!snapshot.hasData ||
                snapshot.data == null && snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  S.of(context).startConversation,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: ColorSchemes.black,
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              final massages = snapshot.data!;
              return GroupedListView<dynamic, DateTime>(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                reverse: true,
                elements: massages,
                controller: widget.massagesScrollController,
                groupBy: (massage) => DateTime(massage.timeSent.year,
                    massage.timeSent.month, massage.timeSent.day),
                groupHeaderBuilder: (massage) => buildDateWidget(
                  context: context,
                  dateTime: massage.timeSent,
                ),
                useStickyGroupSeparators: true,
                floatingHeader: true,
                order: GroupedListOrder.DESC,
                itemBuilder: (context, massage) {
                  // //add list view scroll to bottom
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   widget.massagesScrollController.animateTo(
                  //     widget.massagesScrollController.position.minScrollExtent,
                  //     duration: const Duration(milliseconds: 300),
                  //     curve: Curves.easeInOut,
                  //   );
                  // });
                  //set massage as seen in fireStore
                  double myMassagePadding = massage.reactions.isEmpty ? 8 : 20;
                  double otherMassagePadding = massage.reactions.isEmpty ? 8 : 25;
                  if (widget.groupId.isNotEmpty) {
                    BlocProvider.of<ChatsBloc>(context).setMassageAsSeen(
                      senderId: widget.currentUser.uId,
                      receiverId: widget.friendId,
                      massageId: massage.messageId,
                      isGroupChat: widget.groupId.isNotEmpty,
                      isSeenByList: massage.isSeenBy,
                    );
                  } else {
                    if (massage.isSeen == false &&
                        massage.senderId != widget.currentUser.uId) {
                      BlocProvider.of<ChatsBloc>(context).setMassageAsSeen(
                        senderId: widget.currentUser.uId,
                        receiverId: widget.friendId,
                        massageId: massage.messageId,
                        isGroupChat: widget.groupId.isNotEmpty,
                        isSeenByList: massage.isSeenBy,
                      );
                    }
                  }
                  bool isMe = massage.senderId == widget.currentUser.uId;
                  return Stack(
                    children: [
                      GestureDetector(
                        onLongPress: () async {
                          _showReactionDialog(isMe, massage, context);
                          // final value = await Navigator.of(context).push(
                          //   HeroDialogRoute(
                          //     builder: (context) {
                          //       return ReactionsContextMenu(
                          //         isMe: isMe,
                          //         massage: massage,
                          //         onContextMenuSelected: (emoji, massage) {
                          //           widget.onContextMenuSelected(
                          //               emoji, massage);
                          //         },
                          //         onEmojiSelected: (emoji, massage) {
                          //           widget.onEmojiSelected(emoji, massage);
                          //         },
                          //       );
                          //     },
                          //   ),
                          // );
                          // // if (value! == true) {
                          // //   //show emoji keyboard
                          // //   widget.showEmojiKeyword(massage);
                          // // }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 8.0,
                            bottom: isMe ? myMassagePadding : otherMassagePadding,
                          ),
                          child: MassageWidget(
                            massage: massage,
                            isMe: isMe,
                            isViewOnly: false,
                            isGroupChat: widget.groupId.isNotEmpty,
                            onRightSwipe: () {
                              print("onRightSwipe${massage.massage}");
                              final massageReply = MassageReply(
                                massage: massage.massage,
                                senderName: massage.senderName,
                                senderId: massage.senderId,
                                senderImage: massage.senderImage,
                                massageType: massage.massageType,
                                isMe: isMe,
                              );
                              // _bloc.setMassageReply(massageReply);
                              widget.onRightSwipe(massageReply);
                            },
                          ),
                        ),
                      ),
                      _stackedReactions(massage, isMe),
                    ],
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

  void _showReactionDialog(bool isMe, massage, BuildContext context) {
    showReactionsDialog(
      context: context,
      massage: massage,
      isMe: isMe,
      groupId: widget.groupId,
      onContextMenuSelected: (emoji, massage) {
        widget.onContextMenuSelected(emoji, massage);
      },
      onEmojiSelected: (emoji, massage) {
        widget.onEmojiSelected(emoji, massage);
      },
    );
  }

  Widget _stackedReactions(massage, bool isMe) {
    return isMe
        ? Positioned(
            bottom: 4,
            right: 90,
            child: StackedReactionsWidget(
              massage: massage,
              size: 20,
              onPressed: () {
                //show bottom sheet with list of people reactions with massage
              },
            ),
          )
        : Positioned(
            bottom: 4,
            left: 50,
            child: StackedReactionsWidget(
              massage: massage,
              size: 20,
              onPressed: () {
                //show bottom sheet with list of people reactions with massage
              },
            ),
          );
  }
}
