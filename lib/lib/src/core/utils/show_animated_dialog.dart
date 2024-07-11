import 'package:flutter/material.dart';

void showAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String textAction,
  required Function(bool) onActionTap,
}) {
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
        scale: Tween<double>(begin: 0.5, end: 1).animate(animation1),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1).animate(animation1),
          child: AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Text(
              content,
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onActionTap(false);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onActionTap(true);
                },
                child:Text(textAction),
              ),
            ],
          ),
        ),
      );
    },
  );
}
