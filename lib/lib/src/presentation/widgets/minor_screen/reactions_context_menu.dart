import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/massage_to_show_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/my_massage_widget.dart';

class ReactionsContextMenu extends StatefulWidget {
  final bool isMe;
  final Massage massage;
  final void Function(String, Massage) onEmojiSelected;
  final void Function(String, Massage) onContextMenuSelected;

  const ReactionsContextMenu({
    super.key,
    required this.isMe,
    required this.massage,
    required this.onEmojiSelected,
    required this.onContextMenuSelected,
  });

  @override
  State<ReactionsContextMenu> createState() => _ReactionsContextMenuState();
}

class _ReactionsContextMenuState extends State<ReactionsContextMenu> {
  //list of default reactions
  final List<String> _reactions = ["👍", "❤️", "😂", "😮", "😢", "😡", "➕"];
  final List<String> _contextMenu = [
    Constants.reply,
    Constants.copy,
    Constants.delete
  ];
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
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
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
                                    reaction, widget.massage);
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
              Hero(
                tag: widget.massage.messageId,
                child: MyMassageWidget(
                  massage: widget.massage,
                  isReplying: widget.massage.repliedTo.isNotEmpty,
                  isGroupChat: true,
                  setMassageReplyNull: () {},
                ),
                // child: _alignMassageReplyWidget(context),
              ),
              Align(
                alignment: Alignment.centerRight,
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
                          InkWell(
                            onTap: () {
                              widget.onContextMenuSelected(
                                  contextMenu, widget.massage);
                              setState(() {
                                contextMenuClicked = true;
                                clickedContextMenuIndex =
                                    _contextMenu.indexOf(contextMenu);
                              });
                              //set the reaction back
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                if (mounted) {
                                  setState(() {
                                    contextMenuClicked = false;
                                  });
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(contextMenu,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      )),
                                  Pulse(
                                    infinite: false,
                                    duration: const Duration(milliseconds: 500),
                                    animate: contextMenuClicked &&
                                        clickedContextMenuIndex ==
                                            _contextMenu.indexOf(contextMenu),
                                    child: Icon(
                                        contextMenu == Constants.reply
                                            ? Icons.reply
                                            : contextMenu == Constants.copy
                                                ? Icons.copy
                                                : Icons.delete,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  )
                                ],
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

  Widget _alignMassageReplyWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: widget.isMe
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[400],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: MassageToShowWidget(
          massageType: widget.massage.massageType,
          massage: widget.massage.massage,
          context: context,
        ),
      ),
    );
  }
}
