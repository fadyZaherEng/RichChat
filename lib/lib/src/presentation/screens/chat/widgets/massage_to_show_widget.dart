import 'package:flutter/material.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';

class MassageToShowWidget extends StatelessWidget {
  final MassageType massageType;
  final String massage;
  final BuildContext context;

  const MassageToShowWidget({
    required this.massageType,
    required this.massage,
    required this.context,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return massageReplayShow();
  }

  Widget massageReplayShow() {
    switch (massageType) {
      case MassageType.text:
        return Text(
          massage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        );
      case MassageType.image:
        return Row(
          children: [
            const Icon(Icons.image_outlined),
            const SizedBox(
              width: 10,
            ),
            Text(
              S.of(context).image,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      case MassageType.video:
        return Row(
          children: [
            Icon(Icons.video_library_outlined,
                color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 10),
            Text(
              S.of(context).video,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      case MassageType.audio:
        return Row(
          children: [
            Icon(Icons.audiotrack_outlined,
                color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 10),
            Text(
              S.of(context).audio,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      case MassageType.file:
        return Row(
          children: [
            Icon(Icons.file_copy_outlined,
                color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 10),
            Text(
              S.of(context).file,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      default:
        return Text(
          massage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        );
    }
  }
}
