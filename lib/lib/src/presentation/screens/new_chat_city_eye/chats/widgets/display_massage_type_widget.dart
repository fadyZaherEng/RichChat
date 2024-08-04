import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_eye/src/config/routes/routes_manager.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/utils/massage_type.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/audio_wave_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/show_audio_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/show_video_widget.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skeletons/skeletons.dart';

class DisplayMassageTypeWidget extends StatefulWidget {
  final String massage;
  final MassageType massageType;
  final Color color;
  final TextOverflow? textOverflow;
  final bool isReplying;
  final int? maxLines;

  const DisplayMassageTypeWidget({
    super.key,
    required this.massageType,
    required this.massage,
    required this.color,
    this.maxLines,
    this.textOverflow,
    required this.isReplying,
  });

  @override
  State<DisplayMassageTypeWidget> createState() =>
      _DisplayMassageTypeWidgetState();
}

class _DisplayMassageTypeWidgetState extends State<DisplayMassageTypeWidget> {
  Directory? appDirectory;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    appDirectory = await getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return _getMassageTypeWidget();
  }

  Widget _getMassageTypeWidget() {
    switch (widget.massageType) {
      case MassageType.text:
        return Text(
          widget.massage,
          style: TextStyle(
            fontSize: 16,
            color: widget.color,
            overflow: widget.textOverflow,
          ),
          maxLines: widget.maxLines,
        );
      case MassageType.image:
        return widget.isReplying
            ? const Icon(Icons.image)
            : SizedBox(
                height: 200,
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: widget.massage,
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
        return widget.isReplying
            ? const Icon(Icons.video_collection)
            : ShowVideoWidget(
                videoPath: widget.massage,
                color: widget.color,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.playVideoFullScreen,
                    arguments: {
                      'videoPath': widget.massage,
                    },
                  );
                },
              );
      case MassageType.audio:
        return widget.isReplying
            ? Icon(Icons.audiotrack, color: ColorSchemes.iconBackGround)
            :
        // AudioWaveWidget(path: widget.massage);
        ShowAudioWidget(
          audioPath: widget.massage,
          textDurationColor: widget.color,
        );
      case MassageType.file:
        return SizedBox(
          height: 200,
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: widget.massage,
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
      default:
        return Text(
          widget.massage,
          style: TextStyle(
            fontSize: 16,
            color: widget.color,
            overflow: widget.textOverflow,
          ),
          maxLines: widget.maxLines,
        );
    }
  }
}
