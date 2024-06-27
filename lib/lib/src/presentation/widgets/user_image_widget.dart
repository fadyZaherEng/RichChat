import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class UserImageWidget extends StatelessWidget {
  final String image;
  final bool isBorder;
  double width;
  double height;

  UserImageWidget({
    super.key,
    required this.image,
    this.isBorder = true,
    this.width = 40.0,
    this.height = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
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
      errorWidget: (context, url, error) => const Image(
        image: NetworkImage(
          "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png",
        ),
      ),
    );
  }
}
