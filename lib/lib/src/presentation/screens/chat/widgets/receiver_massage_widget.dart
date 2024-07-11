import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/widgets/stacked_reactions.dart';
import 'package:intl/intl.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_type_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/massage_reply_preview_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class ReceiverMassageWidget extends StatelessWidget {
  final Massage massage;
  final bool isReplying;
  final bool isGroupChat;
  final bool viewOnly;
  final void Function() setMassageReplyNull;

  const ReceiverMassageWidget({
    super.key,
    required this.massage,
    required this.isReplying,
    required this.isGroupChat,
    this.viewOnly = false,
    required this.setMassageReplyNull,
  });

  @override
  Widget build(BuildContext context) {
    final senderName = massage.repliedTo == S.of(context).you
        ? S.of(context).you
        : massage.senderName;
    final padding = massage.reactions.isNotEmpty
        ? const EdgeInsets.only(right: 20.0, bottom: 25.0)
        : const EdgeInsets.only(bottom: 0.0);
    final massageReactions =
        massage.reactions.map((e) => e.split("=")[1]).toList();
    print("isGroupChat: $isGroupChat");
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.15,
        ),
        child: Row(
          children: [
            if (isGroupChat)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: InkWell(
                  onTap: () {},
                  child: UserImageWidget(
                    image: massage.senderImage,
                    height: 30,
                    width: 30,
                    isBorder: false,
                  ),
                ),
              ),
            Stack(
              children: [
                Padding(
                  padding: padding,
                  child: Card(
                    elevation: 5,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    color: Theme.of(context).cardColor,
                    child: Stack(
                      children: [
                        Padding(
                          padding: massage.massageType == MassageType.text
                              ? const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0)
                              : const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isReplying) ...[
                                  MassageReplyPreviewWidget(
                                    massage: massage,
                                    viewOnly: viewOnly,
                                    setReplyMessageWithNull: () {
                                      setMassageReplyNull();
                                    },
                                  )
                                ],
                                DisplayMassageTypeWidget(
                                  massageType: massage.massageType,
                                  massage: massage.massage,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  context: context,
                                  isReplying: false,
                                  viewOnly: viewOnly,
                                ),
                                Text(
                                  DateFormat("hh:mm a")
                                      .format(massage.timeSent),
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white60
                                          : Colors.grey.shade500,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 50,
                    child: //TODO: Add Package StackedReactions
                        StackedReactions(
                      reactions: massageReactions,
                    )
                    //TODO: Add My StackedReactionsWidget
                    //  StackedReactionsWidget(
                    //                 massage: massage,
                    //                 size: 20,
                    //                 onPressed: () {
                    //                   //show bottom sheet with list of people reactions with massage
                    //                 },
                    //               ),
                    )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
