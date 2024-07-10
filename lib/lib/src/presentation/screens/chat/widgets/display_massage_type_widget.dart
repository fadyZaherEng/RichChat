import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/show_audio_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/show_video_widget.dart';
import 'package:skeletons/skeletons.dart';

class DisplayMassageTypeWidget extends StatelessWidget {
  final String massage;
  final MassageType massageType;
  final Color color;
  final TextOverflow? textOverflow;
  final bool isReplying;
  final bool viewOnly;
  final int? maxLines;
  final BuildContext context;

  const DisplayMassageTypeWidget({
    super.key,
    required this.massageType,
    required this.massage,
    required this.color,
    this.maxLines,
    this.textOverflow,
    required this.context,
    required this.isReplying,
    required this.viewOnly,
  });

  @override
  Widget build(BuildContext context) {
    return getMassageTypeWidget();
  }

  Widget getMassageTypeWidget() {
    switch (massageType) {
      case MassageType.text:
        return Text(
          massage,
          style: TextStyle(fontSize: 16, color: color, overflow: textOverflow),
          maxLines: maxLines,
        );
      case MassageType.image:
        return isReplying
            ? const Icon(Icons.image)
            : SizedBox(
          height: 200,
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: massage,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 200,
                    width: 200,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
          ),
        );
      case MassageType.video:
        return isReplying
            ? const Icon(Icons.video_collection)
            : ShowVideoWidget(
          videoPath: massage,
          color: color,
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.fullVideoScreen,
              arguments: {
                'videoPath': massage,
              },
            );
          },
          isViewOnly: viewOnly,
        );
      case MassageType.audio:
        return isReplying
            ? Icon(Icons.audiotrack,
            color: Theme.of(context).colorScheme.secondary)
            : ShowAudioWidget(
          audioPath: massage,
          textDurationColor: color,
          viewOnly: viewOnly,
        );
      case MassageType.file:
        return CachedNetworkImage(imageUrl: massage);
      default:
        return Text(
          massage,
          style: TextStyle(fontSize: 16, color: color, overflow: textOverflow),
          maxLines: maxLines,
        );
    }
  }
}
