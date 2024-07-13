import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class UserImageWidget extends StatelessWidget {
  final String image;
  final File? fileImage;
  final bool isBorder;
  double width;
  double height;

  UserImageWidget({
    super.key,
    required this.image,
    this.isBorder = true,
    this.width = 40.0,
    this.height = 40.0,
    this.fileImage,
  });

  @override
  Widget build(BuildContext context) {
    return fileImage != null
        ? CircleAvatar(
            radius: 40.0,
            backgroundImage: FileImage(fileImage!),
          )
        : CachedNetworkImage(
            imageUrl: image,
            imageBuilder: (context, imageProvider) => Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  border: isBorder
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.0,
                        )
                      : null),
            ),
            placeholder: (context, url) => SkeletonAvatar(
              style: SkeletonAvatarStyle(
                width: width,
                height: height,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: width,
              height: height,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png",
                  ),
                  fit: BoxFit.cover,
                  // colorFilter: ColorFilter.mode(
                  //   Theme.of(context).colorScheme.primary,
                  //   BlendMode.srcATop,
                  // ),
                ),
              ),
            ),
          );
  }
}
