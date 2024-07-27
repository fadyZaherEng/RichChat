import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: ColorSchemes.lightGray.withOpacity(0.1),
              blurRadius: 0.24,
              spreadRadius: 0,
              offset: const Offset(0, 4))
        ],
      ),
      child: Lottie.asset(
        ImagePaths.log2,
        repeat: true,
        reverse: true,
        animate: true,
        height: 200,
        width: 200,
        frameBuilder: (BuildContext context, Widget? child, _) {
          return child!;
        },
      ),
    );
  }
}
