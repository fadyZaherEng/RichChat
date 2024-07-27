import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';

mixin LoadingManager {
  void runChangeState();

  String? message;
  bool isLoading = false;
  bool isLoadingWithMessage = false;

  void showLoading() async {
    if (!isLoading) {
      isLoading = true;
      runChangeState();
    }
  }

  void hideLoading() async {
    if (isLoading) {
      isLoading = false;
      runChangeState();
    }
  }

  Widget loadingManagerWidget(BuildContext context) {
    if (isLoading) {
      return customLoadingWidget(context);
    } else if (isLoadingWithMessage) {
      return customLoadingMessageWidget(message);
    } else {
      return const SizedBox.shrink();
    }
  }

  /// use this method if you want to change the default loading login_widget
  Widget customLoadingWidget(BuildContext context) {
    return InkWell(
      onTap: null,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: LoadingAnimationWidget.threeArchedCircle(
          color: Theme.of(context).colorScheme.primary,
          size: 50,
        )),
      ),
    );
  }

  /// use this method if you want to change the default loading login_widget with
  /// it's message
  /// [message] --> refer to the message that you want to display
  /// that already submitted using [showMessageLoading]
  Widget customLoadingMessageWidget(String? message) {
    return Container();
  }
}
