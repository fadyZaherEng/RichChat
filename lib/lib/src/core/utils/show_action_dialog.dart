import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/action_dialog_widget.dart';

Future showActionDialogWidget({
  required BuildContext context,
  required String text,
   String icon="",
  IconData?iconData,
  required String primaryText,
  required String secondaryText,
  required Function() primaryAction,
  required Function() secondaryAction,
  Color? iconColor,
}) async {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ActionDialogWidget(
              text: text,
              icon: icon,
              iconData: iconData,
              primaryText: primaryText,
              secondaryText: secondaryText,
              primaryAction: primaryAction,
              secondaryAction: secondaryAction,
              iconColor: iconColor,
            ),
          )));
}
