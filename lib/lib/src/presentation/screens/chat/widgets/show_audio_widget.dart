// ignore_for_file: must_be_immutable, deprecated_member_use
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';

class ShowAudioWidget extends StatefulWidget {
  final String audioPath;
  final Color textDurationColor;
  final bool viewOnly;

  const ShowAudioWidget({
    Key? key,
    required this.audioPath,
    required this.textDurationColor,
    this.viewOnly = false,
  }) : super(key: key);

  @override
  State<ShowAudioWidget> createState() => _ShowAudioWidgetState();
}

//issue in counter maintain value of previous sole it in video in course review this section again
class _ShowAudioWidgetState extends State<ShowAudioWidget> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    // // init audio player
    // audioPlayer = AudioPlayer();
    // isPlaying = false;
    // duration = Duration.zero;
    // position = Duration.zero;
    // _isMuted = false;
    if (mounted) {
      audioPlayer.play(UrlSource(widget
          .audioPath)); //here issues in video in course review this section again
      audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          setState(() {
            isPlaying = false;
            position = Duration.zero;
          });
        }
        if (state == PlayerState.playing) {
          setState(() {
            isPlaying = true;
          });
        }
        if (state == PlayerState.paused) {
          setState(() {
            isPlaying = false;
          });
        }
      });
      // set audio duration
      audioPlayer.onDurationChanged.listen((newDuration) {
        if (mounted) {
          setState(() {
            duration = newDuration;
          });
        }
      });
      //set audio position
      audioPlayer.onPositionChanged.listen((newPosition) {
        if (mounted) {
          setState(() {
            position = newPosition;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (_isMuted) {
                audioPlayer.setVolume(1);
                setState(() {
                  _isMuted = false;
                });
              } else {
                audioPlayer.setVolume(0);
                setState(() {
                  _isMuted = true;
                });
              }
            },
            child: SvgPicture.asset(
              _isMuted ? ImagePaths.icVolumeMute : ImagePaths.icVolume,
              fit: BoxFit.scaleDown,
              color: Theme.of(context).cardColor,
              height: 20,
              width: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatTime(duration - position),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: widget.textDurationColor),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 1.2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                activeTickMarkColor: Theme.of(context).cardColor,
                inactiveTickMarkColor: Theme.of(context).primaryColor,
                activeTrackColor: Theme.of(context).cardColor,
                inactiveTrackColor: Theme.of(context).primaryColor,
                disabledThumbColor: Theme.of(context).primaryColor,
              ),
              child: Slider.adaptive(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                activeColor: Theme.of(context).cardColor,
                inactiveColor: Theme.of(context).primaryColor,
                // thumbColor: Theme.of(context).cardColor,
                onChanged: (value) async {
                  await audioPlayer.seek(Duration(seconds: value.toInt()));
                  await audioPlayer.resume();
                },
              ),
            ),
          ),
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.orangeAccent,
            child: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.white,
              child: InkWell(
                onTap: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                    setState(() {
                      isPlaying = false;
                    });
                  } else {
                    await audioPlayer.play(DeviceFileSource(widget.audioPath));
                    setState(() {
                      isPlaying = true;
                    });
                  }
                },
                child: SvgPicture.asset(
                  isPlaying ? ImagePaths.icPause : ImagePaths.icPlay,
                  matchTextDirection: true,
                  fit: BoxFit.scaleDown,
                  color: ColorSchemes.black,
                  width: 15,
                  height: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

// @override
// void dispose() {
//   audioPlayer.pause();
//   audioPlayer.stop();
//   audioPlayer.dispose();
//   super.dispose();
// }
}
