import 'package:city_eye/generated/l10n.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:city_eye/src/presentation/widgets/build_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

class PlayVideoFullScreen extends StatefulWidget {
  final String videoPath;

  const PlayVideoFullScreen({
    Key? key,
    required this.videoPath,
  }) : super(key: key);

  @override
  State<PlayVideoFullScreen> createState() => _PlayVideoFullScreenState();
}

class _PlayVideoFullScreenState extends State<PlayVideoFullScreen>
    with WidgetsBindingObserver {
 late VideoPlayerController videoController;
  @override
  void initState() {
      videoController =
      VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
        ..addListener(() { })
        ..initialize().then((_) {
          videoController.setVolume(1);
        });

    WidgetsBinding.instance.addObserver(this);
    videoController.play();

    videoController.addListener(() {
      if (videoController.value.position ==
          videoController.value.duration) {
        if(mounted) {
          setState(() {});
        }
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    videoController.addListener(() {
      if (videoController.value.position ==
          videoController.value.duration) {
        if(mounted) {
          setState(() {});
        }
      }
    });
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed &&
        !videoController.value.isCompleted) {
      videoController.play();
    } else if (!videoController.value.isCompleted) {
      videoController.pause();
    }
    setState(() {});
  }

  @override
  void deactivate() {
    videoController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    videoController.pause();
    videoController.seekTo(const Duration(seconds: 0));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBarWidget(
        context,
        title: S.of(context).video,
        isHaveBackButton: true,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        color: ColorSchemes.black.withOpacity(0.8),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.loose,
          children: [
            VideoPlayer(
              videoController,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                videoController.value.isPlaying
                    ? videoController.pause()
                    : videoController.play();
                setState(() {});
              },
              child: Stack(
                children: <Widget>[
                  _buildPlay(),
                  Positioned(
                      left: 8,
                      bottom: 28,
                      child: StreamBuilder<String>(
                          stream: getVideoPosition(),
                          builder: (context, snapshot) {
                            return Text(snapshot.data ?? "");
                          })),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          Expanded(child: _buildIndicator()),
                          const SizedBox(width: 8),
                        ],
                      )),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  Stream<String> getVideoPosition() async* {
    while (videoController.value.isPlaying) {
      final duration = Duration(
          milliseconds:
              videoController.value.position.inMilliseconds.round());
      yield [duration.inMinutes, duration.inSeconds]
          .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          .join(':');
      await Future.delayed(const Duration(seconds: 1));
    }

    final duration = Duration(
        milliseconds:
            videoController.value.position.inMilliseconds.round());
    yield [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  Widget _buildIndicator() => Container(
        margin: const EdgeInsets.all(8).copyWith(right: 0),
        height: 16,
        child: VideoProgressIndicator(
          videoController,
          allowScrubbing: true,
        ),
      );

  Widget _buildPlay() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 50),
        reverseDuration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black26,
          child: Center(
            child: SvgPicture.asset(
              fit: BoxFit.scaleDown,
              _isPlayIcon(videoController.value.isPlaying),
              color: Colors.white,
              width: 45,
              height: 45,
            ),
          ),
        ),
      );

  String _isPlayIcon(bool isPlaying) {
    if (isPlaying) {
      setState(() {});
      return ImagePaths.pause;
    } else {
      setState(() {});
      return ImagePaths.play;
    }
  }
}
