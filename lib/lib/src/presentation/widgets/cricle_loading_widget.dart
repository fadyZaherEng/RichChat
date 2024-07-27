import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CircleLoadingWidget extends StatelessWidget {
  final double? size;

  const CircleLoadingWidget({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
      color: Theme.of(context).colorScheme.primary,
      size: size!,
    ));
  }
}
