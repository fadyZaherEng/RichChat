import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_type_widget.dart';

class MyMassageWidget extends StatelessWidget {
  final Massage massage;
  final bool isReplying;
  final bool isGroupChat;

  const MyMassageWidget({
    super.key,
    required this.massage,
    required this.isReplying,
    required this.isGroupChat,
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
        ? const EdgeInsets.only(left: 20, bottom: 50)
        : const EdgeInsets.only(bottom: 0);
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.3,
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
                    bottomLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                color: Colors.deepPurple,
                child: Stack(
                  children: [
                    Padding(
                      padding: massage.massageType == MassageType.text
                          ? const EdgeInsets.fromLTRB(10, 5, 10, 10)
                          : massage.massageType == MassageType.video
                              ? const EdgeInsets.fromLTRB(5, 0, 5, 10)
                              : const EdgeInsets.fromLTRB(5, 5, 5, 10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (isReplying) ...[
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .cardColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      massage.repliedTo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                    DisplayMassageTypeWidget(
                                      massageType: massage.repliedMessageType,
                                      massage: massage.repliedMessage,
                                      color: Colors.white,
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
                              color: Colors.white,
                              context: context,
                              isReplying: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 10,
                      child: Row(
                        children: [
                          Text(
                            DateFormat("hh:mm a").format(massage.timeSent),
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
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
