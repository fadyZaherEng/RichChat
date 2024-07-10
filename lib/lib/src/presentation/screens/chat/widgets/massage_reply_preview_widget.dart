import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage_reply.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_type_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/massage_to_show_widget.dart';

class MassageReplyPreviewWidget extends StatelessWidget {
  final MassageReply? massageReply;
  final Massage? massage;
  final bool viewOnly;
  final void Function() setReplyMessageWithNull;

  const MassageReplyPreviewWidget({
    super.key,
    this.massageReply,
    this.massage,
    required this.setReplyMessageWithNull,
    this.viewOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final type =
        massageReply != null ? massageReply!.massageType : massage!.massageType;
    return IntrinsicHeight(
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(8.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(width: 10),
              _namedAndTypeWidget(type: type, context: context),
              const Spacer(),
              _closedButtonWidget(context),
            ],
          ),
        ),
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
          color: Colors.blue,
        ),
      );
    }
    return Text(
      massage!.repliedTo,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _closedButtonWidget(BuildContext context) {
    return InkWell(
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
                .withOpacity(0.02),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .color!
                  .withOpacity(0.5),
              width: 1,
            )),
        child: const Icon(
          Icons.close,
          size: 18,
        ),
      ),
    );
  }

  Widget _namedAndTypeWidget({
    required MassageType type,
    required BuildContext context,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getTitle(),
          const SizedBox(height: 5),
          massageReply != null
              ?  MassageToShowWidget(
            massage: massageReply!.massage,
            massageType: type,
            context: context,
          ) : DisplayMassageTypeWidget(
            massage: massage!.massage,
            isReplying: true,
            context: context,
            massageType: type,
            textOverflow: TextOverflow.ellipsis,
            maxLines: 1,
            color: Colors.white,
            viewOnly: viewOnly,
          ),

        ],
      ),
    );
  }
}
