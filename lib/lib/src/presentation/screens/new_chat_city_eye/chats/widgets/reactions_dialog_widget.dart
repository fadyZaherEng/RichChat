import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/utils/constants.dart';
import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/my_massage_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/receiver_massage_widget.dart';
import 'package:flutter/material.dart';

class ReactionsDialogWidget extends StatefulWidget {
  final bool isMe;
  final Massage message;
  final void Function(String, Massage) onEmojiSelected;
  final void Function(String, Massage) onContextMenuSelected;
  final void Function() setMassageReplyNull;
  final int currentUserId;

  const ReactionsDialogWidget({
    super.key,
    required this.isMe,
    required this.message,
    required this.onEmojiSelected,
    required this.onContextMenuSelected,
    required this.setMassageReplyNull,
    required this.currentUserId,
  });

  @override
  State<ReactionsDialogWidget> createState() => _ReactionsDialogWidgetState();
}

class _ReactionsDialogWidgetState extends State<ReactionsDialogWidget> {
  //list of default reactions
  final List<String> _reactions = ["👍", "❤️", "😂", "😮", "😢", "😡", "➕"];
  final List<String> _contextMenu = ["Reply", "Copy", "Delete"];
  bool reactionClicked = false;
  int clickedReactionIndex = -1;
  bool contextMenuClicked = false;
  int clickedContextMenuIndex = -1;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment:
                      widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ColorSchemes.white,
                        boxShadow: [
                          BoxShadow(
                            color: ColorSchemes.iconBackGround,
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                         mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var reaction in _reactions)
                            FadeInRight(
                              duration: const Duration(milliseconds: 500),
                              from: 0 + (_reactions.indexOf(reaction) * 20),
                              child: InkWell(
                                onTap: () {
                                  widget.onEmojiSelected(reaction, widget.message);
                                  setState(() {
                                    reactionClicked = true;
                                    clickedReactionIndex =
                                        _reactions.indexOf(reaction);
                                  });
                                  //set the reaction back
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    setState(() {
                                      reactionClicked = false;
                                    });
                                  });
                                },
                                child: Pulse(
                                  duration: const Duration(milliseconds: 500),
                                  animate: reactionClicked &&
                                      clickedReactionIndex ==
                                          _reactions.indexOf(reaction),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      reaction,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: ColorSchemes.black,
                                        fontSize: 20,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                //newly added
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  from: 100,
                  child: widget.isMe
                      ? MyMassageWidget(
                          massage: widget.message,
                          isReplying: widget.message.repliedTo.isNotEmpty,
                          setMassageReplyNull: widget.setMassageReplyNull,
                          uid: widget.currentUserId,
                        )
                      : ReceiverMassageWidget(
                          massage: widget.message,
                          isReplying: widget.message.repliedTo.isNotEmpty,
                          setMassageReplyNull: widget.setMassageReplyNull,
                        ),
                  // child: _alignMassageReplyWidget(context),
                ),
                Align(
                  alignment:
                      widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ColorSchemes.white,
                        boxShadow: [
                          BoxShadow(
                            color: ColorSchemes.iconBackGround,
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var contextMenu in _contextMenu)
                            FadeInLeft(
                              duration: const Duration(milliseconds: 500),
                              from: 0 + (_reactions.indexOf(contextMenu) * 20),
                              child: InkWell(
                                onTap: () {
                                  widget.onContextMenuSelected(
                                      contextMenu, widget.message);
                                  setState(() {
                                    contextMenuClicked = true;
                                    clickedContextMenuIndex =
                                        _contextMenu.indexOf(contextMenu);
                                  });
                                  //set the reaction back
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    if (mounted) {
                                      setState(() {
                                        contextMenuClicked = false;
                                      });
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        contextMenu,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: ColorSchemes.black,
                                            ),
                                      ),
                                      Pulse(
                                        infinite: false,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        animate: contextMenuClicked &&
                                            clickedContextMenuIndex ==
                                                _contextMenu.indexOf(contextMenu),
                                        child: Icon(
                                          contextMenu == Constants.reply
                                              ? Icons.reply
                                              : contextMenu == Constants.copy
                                                  ? Icons.copy
                                                  : Icons.delete,
                                          color: ColorSchemes.primary,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
