import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/display_massage_type_widget.dart';

class MyMassageWidget extends StatelessWidget {
  final Massage massage;
  final bool isReplying;

  const MyMassageWidget({
    super.key,
    required this.massage,
    required this.isReplying,
  });
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
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
              bottomLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          color: Colors.deepPurple,
          child: Stack(
            children: [
              Padding(
                padding: massage.massageType == MassageType.text
                    ? const EdgeInsets.fromLTRB(10, 5, 20, 20)
                    : massage.massageType == MassageType.video
                        ? const EdgeInsets.fromLTRB(5, 0, 5, 25)
                        : const EdgeInsets.fromLTRB(5, 5, 5, 25),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isReplying) ...[
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.1),
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
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      massage.isSeen ? Icons.done_all : Icons.done,
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
    );
  }
}
