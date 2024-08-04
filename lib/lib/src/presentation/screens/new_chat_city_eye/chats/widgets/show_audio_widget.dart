// ignore_for_file: must_be_immutable, deprecated_member_use
import 'package:audioplayers/audioplayers.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShowAudioWidget extends StatefulWidget {
  final String audioPath;
  final Color textDurationColor;

  const ShowAudioWidget({
    Key? key,
    required this.audioPath,
    required this.textDurationColor,
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
    if (mounted) {
      audioPlayer.setSource(UrlSource(
        widget.audioPath,
      )); //here issues in video in course review this section again
      audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          if(mounted){
            setState(() {
              isPlaying = false;
              position = Duration.zero;
              // audioPlayer.setSourceUrl("");
            });
          }
        }
        if (state == PlayerState.playing) {
          if(mounted){
            setState(() {
              isPlaying = true;
            });
          }
        }
        if (state == PlayerState.paused) {
         if(mounted){
           setState(() {
             isPlaying = false;
           });
         }
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
              _isMuted ? ImagePaths.volumeOff : ImagePaths.volume,
              fit: BoxFit.scaleDown,
              color: ColorSchemes.iconBackGround,
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
                activeTickMarkColor: ColorSchemes.iconBackGround,
                inactiveTickMarkColor: ColorSchemes.primary,
                activeTrackColor: ColorSchemes.iconBackGround,
                inactiveTrackColor: ColorSchemes.primary,
                disabledThumbColor: ColorSchemes.primary,
              ),
              child: Slider.adaptive(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                activeColor: ColorSchemes.iconBackGround,
                inactiveColor: ColorSchemes.primary,
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
              radius: 15,
              backgroundColor: ColorSchemes.white,
              child: InkWell(
                onTap: () async {
                 if(mounted){
                   if (isPlaying) {
                     await audioPlayer.pause();
                     // setState(() {
                     //   isPlaying = false;
                     // });
                   } else {
                     await audioPlayer.play(DeviceFileSource(widget.audioPath));
                     // setState(() {
                     //   isPlaying = true;
                     // });
                   }
                 }
                },
                child: SvgPicture.asset(
                  isPlaying ? ImagePaths.pause : ImagePaths.play,
                  matchTextDirection: true,
                  fit: BoxFit.scaleDown,
                  color: ColorSchemes.black,
                  width: 24,
                  height: 24,
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
}
