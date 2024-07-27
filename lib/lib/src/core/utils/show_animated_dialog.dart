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
                  ? ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, value, child) {
                        return SizedBox(
                          height: value.text.length > 200
                              ? 200
                              : value.text.length > 150
                                  ? 150
                                  : value.text.length > 120
                                      ? 100
                                      : 80,
                          child: TextFormField(
                            controller: controller,
                            // maxLength: content == Constants.changeName ? 20 : 500,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Enter $title',
                              hintText: hintText,
                              counterText: '',
                              hintStyle: Theme.of(context).textTheme.bodySmall,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            expands: true,
                            maxLines: null,
                            textAlign: TextAlign.start,
                            onChanged: (value) {
                              controller.text = value;
                            },
                          ),
                        );
                      },
                    )
                  : Text(content, textAlign: TextAlign.center),
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
