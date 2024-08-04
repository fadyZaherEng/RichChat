// ignore_for_file: avoid_print

import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletons/skeletons.dart';

class ChatAppBar extends StatelessWidget {
  final String compoundName;
  final String compoundLogo;
  final String subscriberName;
  final Function(String) onTapImageProfile;
  final Function() onTapBackArrow;

  const ChatAppBar({
    super.key,
    required this.compoundName,
    required this.compoundLogo,
    required this.subscriberName,
    required this.onTapImageProfile,
    required this.onTapBackArrow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                onTapImageProfile(compoundLogo);
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorSchemes.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    compoundLogo,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SvgPicture.asset(
                            ImagePaths.avatar,
                            fit: BoxFit.fill,
                          ));
                    },
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SkeletonLine(
                            style: SkeletonLineStyle(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: BorderRadius.circular(
                            4,
                          ),
                        )),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subscriberName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ColorSchemes.black,
                            letterSpacing: -0.24,
                          )),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(compoundName,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ColorSchemes.gray,
                              letterSpacing: -0.24,
                            )),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onTapBackArrow,
              child: SvgPicture.asset(
                ImagePaths.arrowRight,
                width: 24,
                height: 24,
                matchTextDirection: true,
                color: ColorSchemes.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
