import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/my_massage_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/receiver_massage_widget.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageWidget extends StatelessWidget {
  final Massage message;
  final Function() onRightSwipe;
  final bool isMe;
  final void Function() setMassageReplyNull;
  final int uid;

  const MessageWidget({
    super.key,
    required this.message,
    required this.onRightSwipe,
    required this.isMe,
    required this.setMassageReplyNull,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: isMe
          ? MyMassageWidget(
              massage: message,
              isReplying: message.repliedTo.isNotEmpty,
              setMassageReplyNull: setMassageReplyNull,
              uid: uid,
            )
          : ReceiverMassageWidget(
              massage: message,
              isReplying: message.repliedTo.isNotEmpty,
              setMassageReplyNull: setMassageReplyNull,
            ),
    );
  }
}
