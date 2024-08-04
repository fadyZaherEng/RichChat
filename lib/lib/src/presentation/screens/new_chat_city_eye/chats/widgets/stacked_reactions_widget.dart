import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:flutter/material.dart';

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
    final massageReaction =
        widget.massage.reactions.map((e) => e.split("=")[1]).toList();
    final reactionShow = massageReaction.length > 4
        ? massageReaction.sublist(0, 4)
        : massageReaction;
    final remainingReactionsLength =
        massageReaction.length - reactionShow.length;
    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        children: _getAllReactions(
          reactions: reactionShow,
          remainingReactionsLength: remainingReactionsLength,
        ),
      ),
    );
  }

  List<Widget> _getAllReactions({
    required List<String> reactions,
    required int remainingReactionsLength,
  }) {
    return reactions
        .asMap()
        .map(
          (index, reaction) {
            return MapEntry(
              index,
              index == reactions.length - 1 && remainingReactionsLength > 0
                  ? Stack(
                      children: [
                        _buildReaction(
                          index: index,
                          reaction: reaction,
                          reactionLengthIsOne: reactions.length == 1,
                        ),
                        if (remainingReactionsLength > 0) ...[
                          Container(
                            margin: EdgeInsets.only(left: index * 22),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                              color: ColorSchemes.white,
                              clipBehavior: Clip.hardEdge,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    child: Text(
                                      '+$remainingReactionsLength',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: ColorSchemes.black,
                                      ),
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
                  : _buildReaction(
                      index: index,
                      reaction: reaction,
                      reactionLengthIsOne: reactions.length == 1,
                    ),
            );
          },
        )
        .values
        .toList();
  }

  Widget _buildReaction({
    required int index,
    required String reaction,
    required bool reactionLengthIsOne,
  }) {
    return Container(
      margin: EdgeInsets.only(left: index * 18),
      padding: reactionLengthIsOne
          ? const EdgeInsets.symmetric(horizontal: 5)
          : const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: ColorSchemes.lightGray,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: ClipOval(
        child: Text(
          reaction,
          style: TextStyle(fontSize: widget.size),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
