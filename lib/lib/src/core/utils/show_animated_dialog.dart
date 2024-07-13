import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';

void showAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String textAction,
  required Function(bool, String) onActionTap,
  bool editable = false,
  String hintText = '',
}) {
  TextEditingController controller = TextEditingController(text: hintText);
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: editable
                  ? TextFormField(
                      controller: controller,
                      maxLength: content == Constants.changeName ? 20 : 500,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: hintText,
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  : Text(
                      content,
                      textAlign: TextAlign.center,
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActionTap(
                      false,
                      controller.text,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActionTap(
                      true,
                      controller.text,
                    );
                  },
                  child: Text(textAction),
                ),
              ],
            ),
          ));
    },
  );
}
