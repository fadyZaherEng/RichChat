import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_type_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/my_massage_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/receiver_massage_widget.dart';
import 'package:swipe_to/swipe_to.dart';

class SwipeToWidget extends StatelessWidget {
  final Function() onRightSwipe;
  final Massage message;
  final bool isMe;
  final bool isGroupChat;
  final void Function() setMassageReplyNull;

  const SwipeToWidget({
    super.key,
    required this.onRightSwipe,
    required this.message,
    required this.isMe,
    required this.isGroupChat,
    required this.setMassageReplyNull,
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
              isGroupChat: isGroupChat,
              setMassageReplyNull: setMassageReplyNull,
            )
          : ReceiverMassageWidget(
              massage: message,
              isGroupChat: isGroupChat,
              isReplying: message.repliedTo.isNotEmpty,
              setMassageReplyNull: setMassageReplyNull,
            ),
    );
  }
}
