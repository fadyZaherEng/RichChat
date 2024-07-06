import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage_reply.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_reply_type_widget.dart';

class MassageReplyWidget extends StatelessWidget {
  final MassageReply? massageReply;
  final Massage? massage;
  final void Function() setReplyMessageWithNull;

  const MassageReplyWidget({
    super.key,
    this.massageReply,
    this.massage,
    required this.setReplyMessageWithNull,
  });

  @override
  Widget build(BuildContext context) {
    final type =
        massageReply != null ? massageReply!.massageType : massage!.massageType;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.primary),
          left: BorderSide(color: Theme.of(context).colorScheme.primary),
          right: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              )),
          const SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              getTitle(),
              MassageReplyTypeWidget(
                massage: massageReply!.massage,
                massageType: type,
                context: context,
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              //TODO: set reply to null
              setReplyMessageWithNull();
            },
            child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .color!
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Theme.of(context).textTheme.titleLarge!.color!,
                      width: 1,
                    )),
                child: const Icon(Icons.close)),
          ),
        ],
      ),
    );
  }

  Widget getTitle() {
    if (massageReply != null) {
      return Text(
        massageReply!.isMe ? "You" : massageReply!.senderName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Text(
      massage!.senderName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
