import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';

class UserInfoImageWidget extends StatelessWidget {
  final void Function() onCameraClicked;
  final File? image;

  const UserInfoImageWidget({
    super.key,
    required this.onCameraClicked,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCameraClicked,
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          image == null
              ? Image.asset(
                  ImagePaths.user,
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.file(
                    image!,
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                  ),
                ),
          Container(
            padding: const EdgeInsets.all(6),
            margin: EdgeInsetsDirectional.only(
                bottom: image == null ? 20 : 0, start: image == null ? 20 : 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.camera,
              size: 15,
              color: ColorSchemes.white,
            ),
          )
        ],
      ),
    );
  }
}
