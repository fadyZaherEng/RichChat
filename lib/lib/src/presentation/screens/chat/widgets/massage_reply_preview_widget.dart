import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage_reply.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_type_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/massage_to_show_widget.dart';

class MassageReplyPreviewWidget extends StatelessWidget {
  final MassageReply? massageReply;
  final Massage? massage;
  final bool isShowCloseButton;
  final void Function() setReplyMessageWithNull;

  const MassageReplyPreviewWidget({
    super.key,
    this.massageReply,
    this.massage,
    required this.isShowCloseButton,
    required this.setReplyMessageWithNull,
  });

  @override
  Widget build(BuildContext context) {
    final type =
        massageReply != null ? massageReply!.massageType : massage!.massageType;

    final padding = massageReply != null
        ? const EdgeInsets.all(10)
        : const EdgeInsets.only(top: 5, right: 5, bottom: 5);
    final decorationColor = massageReply != null
        ? Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1)
        : Theme.of(context).primaryColorDark.withOpacity(0.2);

    return IntrinsicHeight(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: decorationColor,
          border: const Border(
            top: BorderSide(color: Colors.purple, width: 1),
            left: BorderSide(color: Colors.purple, width: 1),
            right: BorderSide(color: Colors.purple, width: 1),
          ),
          borderRadius: massageReply != null
              ? const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))
              : const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
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
              ),
            ),
            const SizedBox(width: 8),
            _namedAndTypeWidget(type: type, context: context),
            const Spacer(),
            if (isShowCloseButton) _closedButtonWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _getTitle(context) {
    if (massageReply != null) {
      bool isMe = massageReply!.isMe;
      return Text(
        isMe ? "You" : massageReply!.senderName,
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          //fontSize: 12,
        ),
      );
    } else {
      return Text(
        massage!.repliedTo,
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          //fontSize: 12,
        ),
      );
    }
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
          color: Colors.green,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.purple,
            width: 1,
          ),
        ),
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
          _getTitle(context),
          const SizedBox(height: 5),
          massageReply != null
              ? MassageToShowWidget(
                  massage: massageReply!.massage,
                  massageType: type,
                )
              : DisplayMassageTypeWidget(
                  massage: massage!.massage,
                  isReplying: true,
                  massageType: type,
                  textOverflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  color: Colors.white,
                ),
        ],
      ),
    );
  }
}
