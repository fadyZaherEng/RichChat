import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';

class StackedReactionsWidget extends StatefulWidget {
  final Massage massage;
  final double size;
  final void Function() onPressed;

  const StackedReactionsWidget({
    super.key,
    required this.massage,
    required this.size,
    required this.onPressed,
  });

  @override
  State<StackedReactionsWidget> createState() => _StackedReactionsWidgetState();
}

class _StackedReactionsWidgetState extends State<StackedReactionsWidget> {
  @override
  Widget build(BuildContext context) {
    //get reaction from list
    final massageReaction =
        widget.massage.reactions.map((e) => e.split("=")[1]).toList();
    final reactionShow = massageReaction.length > 5
        ? massageReaction.sublist(0, 5)
        : massageReaction;
    final remainingReactionsLength =
        massageReaction.length - reactionShow.length;
    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        children: _getAllReactions(reactionShow, remainingReactionsLength),
      ),
    );
  }

  List<Widget> _getAllReactions(
      List<String> reactions, int remainingReactionsLength) {
    return reactions
        .asMap()
        .map(
          (index, reaction) {
            return MapEntry(
              index,
              index == reactions.length - 1
                  ? Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: index * 18),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow:  [
                                BoxShadow(
                                  color:Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                )
                              ]),
                          child: ClipOval(
                            child: Text(
                              reaction,
                              style: TextStyle(fontSize: widget.size),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (remainingReactionsLength > 0) ...[
                          Container(
                            margin: EdgeInsets.only(left: index * 22),
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                              color: Colors.white,
                              clipBehavior: Clip.hardEdge,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 1),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 1),
                                    child: Text(
                                      '+$remainingReactionsLength',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    )
                  : Container(
                      margin: EdgeInsets.only(left: index * 18),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow:  [
                            BoxShadow(
                              color:Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black12,
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            )
                          ]),
                      child: ClipOval(
                        child: Text(
                          reaction,
                          style: TextStyle(fontSize: widget.size),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            );
          },
        )
        .values
        .toList();
  }
}
