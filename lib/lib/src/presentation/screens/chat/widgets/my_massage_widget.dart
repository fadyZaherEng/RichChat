import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/widgets/stacked_reactions.dart';
import 'package:intl/intl.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_type_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/massage_reply_preview_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/stacked_reactions_widget.dart';

class MyMassageWidget extends StatelessWidget {
  final Massage massage;
  final bool isReplying;
  final bool isGroupChat;
  final bool viewOnly;
  final void Function() setMassageReplyNull;

  const MyMassageWidget({
    super.key,
    required this.massage,
    required this.isReplying,
    required this.isGroupChat,
    this.viewOnly = false,
    required this.setMassageReplyNull,
  });

  bool massageSeen() {
    final uid = FirebaseSingleTon.auth.currentUser!.uid;
    bool seen = false;
    if (isGroupChat) {
      List<String> isSeenBy = massage.isSeenBy;
      if (isSeenBy.contains(uid)) {
        //remove our id then check again
        isSeenBy.remove(uid);
      }
      seen = isSeenBy.isNotEmpty;
    } else {
      seen = massage.isSeen;
    }
    return seen;
  }

  @override
  Widget build(BuildContext context) {
    final padding = massage.reactions.isNotEmpty
        ? const EdgeInsets.only(left: 20.0, bottom: 25.0)
        : const EdgeInsets.only(bottom: 0.0);
    final massageReactions =
        massage.reactions.map((e) => e.split("=")[1]).toList();
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.15,
        ),
        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                color: Colors.deepPurple,
                child: Stack(
                  children: [
                    Padding(
                      padding: massage.massageType == MassageType.text
                          ? const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0)
                          : const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                              color: Colors.white,
                              context: context,
                              isReplying: false,
                              viewOnly: false,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat("hh:mm a")
                                      .format(massage.timeSent),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  massageSeen() ? Icons.done_all : Icons.done,
                                  color: massage.isSeen
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white38,
                                  size: 15,
                                ),
                              ],
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
                bottom: 4,
                right: 30,
                child: //TODO: Add Package StackedReactions
                    StackedReactions(
                  reactions: massageReactions,
                )
                //TODO: Add My StackedReactionsWidget
                // StackedReactionsWidget(
                //   massage: massage,
                //   size: 20,
                //   onPressed: () {
                //     //show bottom sheet with list of people reactions with massage
                //   },
                // ),
                )
          ],
        ),
      ),
    );
  }
}
