// ignore_for_videoPath: deprecated_member_use, must_be_immutable

import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletons/skeletons.dart';
import 'package:video_player/video_player.dart';

class ShowVideoWidget extends StatefulWidget {
  final String videoPath;
  final Color color;
  final void Function() onTap;

  const ShowVideoWidget({
    Key? key,
    required this.videoPath,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ShowVideoWidget> createState() => _ShowVideoWidgetState();
}

class _ShowVideoWidgetState extends State<ShowVideoWidget> {
  late VideoPlayerController videoController;
  bool isPlaying = false;
  bool isLoading = true;

  @override
  void initState() {
    videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
          ..addListener(() {})
          ..initialize().then((_) {
            videoController.setVolume(1);
            setState(() {
              isLoading = false;
            });
          });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 150,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: ColorSchemes.black,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    isLoading?
                     Center(
                      child: SkeletonLine(
                        style: SkeletonLineStyle(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          borderRadius: BorderRadius.circular(15.0),
                        )
                      )
                    ):
                    VideoPlayer(videoController),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 14.0,
                              child: VideoProgressIndicator(
                                videoController,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: ColorSchemes.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: AlignmentDirectional.center,
                        child: GestureDetector(
                          onTap: () {
                            videoController.value.isPlaying
                                ? videoController.pause()
                                : videoController.play();
                            setState(() {});
                          },
                          child: ValueListenableBuilder(
                            valueListenable: videoController,
                            builder: (context, VideoPlayerValue value, child) =>
                                AnimatedSwitcher(
                              duration: const Duration(milliseconds: 50),
                              reverseDuration:
                                  const Duration(milliseconds: 200),
                              child: SvgPicture.asset(
                                value.isPlaying
                                    ? ImagePaths.pause
                                    : ImagePaths.play,
                                fit: BoxFit.scaleDown,
                                width: 32,
                                height: 32,
                                color: widget.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    videoController.dispose();
  }
}
