import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/my_massage_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/receiver_massage_widget.dart';

class ReactionsDialogWidget extends StatefulWidget {
  final bool isMe;
  final Massage message;
  final void Function(String, Massage) onEmojiSelected;
  final void Function(String, Massage) onContextMenuSelected;
  final String groupId;

  const ReactionsDialogWidget({
    super.key,
    required this.isMe,
    required this.message,
    required this.onEmojiSelected,
    required this.onContextMenuSelected,
    required this.groupId,
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
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment:
                    widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
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
                                widget.onEmojiSelected(
                                    reaction, widget.message);
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    reaction,
                                    style: const TextStyle(fontSize: 20),
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
                        isGroupChat: widget.groupId.isNotEmpty,
                      )
                    : ReceiverMassageWidget(
                        massage: widget.message,
                        isReplying: widget.message.repliedTo.isNotEmpty,
                        isGroupChat: widget.groupId.isNotEmpty,
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
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      contextMenu,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
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
                                        color: Colors.black,
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
    );
  }
}
