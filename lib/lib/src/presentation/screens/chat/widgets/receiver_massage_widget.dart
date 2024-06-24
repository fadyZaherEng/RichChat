import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_type_widget.dart';
import 'package:swipe_to/swipe_to.dart';

class ReceiverMassageWidget extends StatelessWidget {
  final Massage massage;
  final void Function() onRightSwipe;

  const ReceiverMassageWidget({
    super.key,
    required this.massage,
    required this.onRightSwipe,
  });

  @override
  Widget build(BuildContext context) {
    final isReplying = massage.repliedTo.isNotEmpty;
    final senderName = massage.repliedTo == S.of(context).you
        ? S.of(context).you
        : massage.senderName;
    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Card(
            elevation: 5,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
            color: Theme.of(context).cardColor,
            child: Stack(
              children: [
                Padding(
                  padding: massage.massageType == MassageType.text
                      ? const EdgeInsets.fromLTRB(10, 5, 20, 20)
                      : massage.massageType == MassageType.video
                          ? const EdgeInsets.fromLTRB(5, 0, 5, 25)
                          : const EdgeInsets.fromLTRB(5, 5, 5, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isReplying) ...[
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                senderName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DisplayMassageTypeWidget(
                                massageType: massage.repliedMessageType,
                                massage: massage.repliedMessage,
                                color: Colors.black,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                                context: context,
                                isReplying: true,
                              ),
                            ],
                          ),
                        )
                      ],
                      DisplayMassageTypeWidget(
                        massageType: massage.massageType,
                        massage: massage.massage,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        context: context,
                        isReplying: false,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        DateFormat("hh:mm a").format(massage.timeSent),
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white60
                                    : Colors.grey,
                            fontSize: 10),
                      ),
                      // const SizedBox(width: 5),
                      // Icon(
                      //   massage.isSeen ? Icons.done_all : Icons.done,
                      //   color: massage.isSeen ? Colors.blue : Colors.white60,
                      //   size: 15,
                      // )
                    ],
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
