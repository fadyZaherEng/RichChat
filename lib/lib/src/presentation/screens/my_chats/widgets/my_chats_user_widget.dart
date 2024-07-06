import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/last_massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/group/group.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_reply_type_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/my_chats/widgets/unread_massage_counter_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/user_image_widget.dart';

class LastMassageChatWidget extends StatelessWidget {
  final LastMassage? chats;
  final Group? group;
  final bool isGroup;
  final void Function() onTap;

  const LastMassageChatWidget({
    super.key,
    this.chats,
    required this.isGroup,
    this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    //get uid
    final uid = GetUserUseCase(injector())().uId;
    //get the last massage
    final lastMassage = chats != null ? chats!.massage : group!.lastMessage;
    //get sender uid
    final senderId = chats != null ? chats!.senderId : group!.senderUID;
    //get date and time
    final dateTime = chats != null ? chats!.timeSent : group!.timeSent;
    final time = DateFormat("hh:mm a").format(dateTime);
    //get image url
    final imageUrl = chats != null ? chats!.receiverImage : group!.groupLogo;
    //get the name
    final name = chats != null ? chats!.receiverName : group!.groupName;
    //get receiver id
    final receiverId = chats != null ? chats!.receiverId : group!.groupID;
    //get the massage type
    final massageType = chats != null ? chats!.massageType : group!.massageType;
    return ListTile(
      titleAlignment: ListTileTitleAlignment.bottom,
      title: Text(
        name,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            uid == senderId
                ? const Text(
                    "You: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(width: 5),
            Expanded(
              child: MassageReplyTypeWidget(
                massageType: massageType,
                massage: lastMassage,
                context: context,
              ),
            ),
          ],
        ),
      ),
      leading: UserImageWidget(
        image: imageUrl,
        width: 50,
        height: 50,
        isBorder: false,
      ),
      trailing: Column(
        children: [
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          UnReadMassageCounterWidget(
            uid: uid,
            receiverId: receiverId,
            isGroup: isGroup,
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
