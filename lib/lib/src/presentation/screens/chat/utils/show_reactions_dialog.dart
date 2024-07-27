import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/reactions_dialog_widget.dart';

void showReactionsDialog({
  required BuildContext context,
  required Massage massage,
  required bool isMe,
  required String groupId,
  required void Function(String,Massage) onContextMenuSelected,
  required void Function(String,Massage) onEmojiSelected,
  required void Function() setMassageReplyNull,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ReactionsDialogWidget(
          message: massage,
          isMe: isMe,
          groupId: groupId,
          onContextMenuSelected: (contextMenu,massage) {
            onContextMenuSelected(contextMenu,massage);
          },
          onEmojiSelected: (emoji,massage) {
            onEmojiSelected(emoji,massage);
          },
          setMassageReplyNull: setMassageReplyNull,
        ),
      ),
    ),
  );
}
