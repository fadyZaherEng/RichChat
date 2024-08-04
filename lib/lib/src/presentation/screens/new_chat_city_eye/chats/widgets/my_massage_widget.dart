import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/utils/massage_type.dart';
import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:city_eye/src/domain/entities/chat/massage_reply.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/display_massage_type_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/massage_reply_preview_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/stacked_reactions_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/widgets/stacked_reactions.dart';
import 'package:intl/intl.dart';

class MyMassageWidget extends StatelessWidget {
  final Massage massage;
  final bool isReplying;
  final int uid;
  final void Function() setMassageReplyNull;

  const MyMassageWidget({
    super.key,
    required this.massage,
    required this.isReplying,
    required this.setMassageReplyNull,
    required this.uid,
  });
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
          minWidth: massageReactions.length > 2
              ? MediaQuery.of(context).size.width * 0.3
              : MediaQuery.of(context).size.width * 0.15,
        ),
        child: Stack(
          alignment: Alignment.centerRight,
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
                color: ColorSchemes.primary.withOpacity(0.8),
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
                                massageReply: MassageReply(
                                  isMe: true,
                                  senderId: massage.senderId.toString(),
                                  senderName: massage.senderName,
                                  massage: massage.repliedMessage,
                                  massageType: massage.repliedMessageType,
                                  senderImage: massage.senderImage,
                                ),
                                setReplyMessageWithNull: () {
                                  setMassageReplyNull();
                                },
                                isShowCloseButton: false,
                              )
                            ],
                            DisplayMassageTypeWidget(
                              massageType: massage.massageType,
                              massage: massage.massage,
                              color: ColorSchemes.white,
                              isReplying: false,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    DateFormat("hh:mm a")
                                        .format(massage.timeSent),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: ColorSchemes.gray,
                                        )),
                                const SizedBox(width: 4),
                                Icon(
                                  _isMassageSeen() ? Icons.done_all : Icons.done,
                                  color: massage.isSeen
                                      ? ColorSchemes.primary
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
            // Positioned(
            //     bottom: 0,
            //     right: 30,
            //     child: //TODO: Add Package StackedReactions
            //     StackedReactions(
            //       size: 22,
            //       reactions: massageReactions,
            //     )
            // ),
            //TODO: Add My StackedReactionsWidget
            Positioned(
              bottom: 5,
              right: 30,
              child: StackedReactionsWidget(
                massage: massage,
                size: 22,
                onPressed: () {
                  //todo show bottom sheet with list of people reactions with massage
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  bool _isMassageSeen() {
    bool seen = false;
    List<int> isSeenBy = massage.isSeenBy;
    if (isSeenBy.contains(uid)) {
      //remove our id then check again
      isSeenBy.remove(uid);
    }
    seen = isSeenBy.isNotEmpty;
    return seen;
  }

}
