// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use, must_be_immutable
import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/permission_service_handler.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_action_dialog.dart';

class RecordVoiceWidget extends StatefulWidget {
  int maxRecordingDuration;
  final FlutterSoundRecord flutterSoundRecord;
  final void Function({
    required File audioFile,
    required bool isSendingButtonShow,
  }) onSendAudio;

  RecordVoiceWidget({
    super.key,
    this.maxRecordingDuration = 60 * 5,
    required this.onSendAudio,
    required this.flutterSoundRecord,
  });

  @override
  _RecordVoiceWidgetState createState() => _RecordVoiceWidgetState();
}

class _RecordVoiceWidgetState extends State<RecordVoiceWidget> {
  bool isRecording = false;
  double playbackProgress = 0.0;
  bool isRecorderReady = false;
  File? audioFile;
  int max = 0;

  bool isShowSendButton = false;

  @override
  void initState() {
    super.initState();
    max = widget.maxRecordingDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onLongPress: () async {
            await _requestMicrophonePermission();
          },
          onLongPressUp: () async {
            _stopRecording();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: isRecording
                  ? Lottie.asset(
                      ImagePaths.mic,
                      fit: BoxFit.cover,
                      width: 35,
                      height: 35,
                    )
                  : SvgPicture.asset(
                      ImagePaths.icMicrophone,
                      fit: BoxFit.scaleDown,
                      width: 20,
                      height: 20,
                      color: Theme.of(context).cardColor,
                    ),
            ),
          ),
        ),
        // to show remaining time from largest recording duration to 0
        // Visibility(
        //   visible: isRecording,
        //   child: StreamBuilder<RecordingDisposition>(
        //       stream: recorder.onProgress,
        //       builder: (context, snapshot) {
        //         final duration =
        //             snapshot.hasData ? snapshot.data!.duration : Duration.zero;
        //         final remainingTime =
        //             Duration(seconds: widget.maxRecordingDuration) - duration;
        //         String twoDigitsInMinutes =
        //             twoDigits(remainingTime.inMinutes.remainder(60));
        //         String twoDigitsInSeconds =
        //             twoDigits(remainingTime.inSeconds.remainder(60));
        //         return Text(
        //           "$twoDigitsInMinutes:$twoDigitsInSeconds",
        //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        //                 letterSpacing: -0.24,
        //                 color: ColorSchemes.black,
        //               ),
        //         );
        //       }),
        // ),
        // const SizedBox(width: 10),
      ],
    );
  }

  Future _startRecording() async {
    if (!isRecorderReady) return;
    setState(() {
      isRecording = true;
    });
    Directory? dir;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    final record =
        await widget.flutterSoundRecord.start(path: "${dir.path}/audio.aac");
    // recorder.onProgress!.listen((event) {
    //   setState(() {
    //     playbackProgress = event.duration.inSeconds.toDouble();
    //     if (playbackProgress > max) {
    //       _stopRecording();
    //     }
    //   });
    // });
    return record;
  }

  Future<void> _stopRecording() async {
    if (!isRecorderReady) return;
    setState(() {
      isRecording = false;
      isShowSendButton = false;
    });
    String audioPath = await widget.flutterSoundRecord.stop() ?? "";

    if (audioPath.isEmpty) {
      ///emit audio path event empty
    } else {
      widget.maxRecordingDuration = max;
      widget.onSendAudio(
        audioFile: File(audioPath),
        isSendingButtonShow: isShowSendButton,
      );
    }
  }

  // @override
  // void dispose() {
  //   recorder.closeRecorder();
  //   super.dispose();
  // }

  String twoDigits(int n) => n.toString().padLeft(2, "0");

  Future _requestMicrophonePermission() async {
    if (await PermissionServiceHandler().handleServicePermission(
      setting: Permission.microphone,
    )) {
      await initRecorder();
      if (await widget.flutterSoundRecord.isRecording()) {
        await _stopRecording();
      } else {
        await _startRecording();
      }
      widget.maxRecordingDuration = max;
    } else if (!await PermissionServiceHandler()
        .handleServicePermission(setting: Permission.microphone)) {
      showActionDialogWidget(
        context: context,
        text: S.of(context).youShouldHaveAudioPermission,
        icon: ImagePaths.icMicrophone,
        primaryText: S.of(context).yes,
        secondaryText: S.of(context).no,
        primaryAction: () async {
          openAppSettings().then((value) => Navigator.pop(context));
        },
        secondaryAction: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  Future initRecorder() async {
    if (Platform.isIOS) {
      await _handleIOSAudio();
    }
    // await recorder.openRecorder();
    isRecorderReady = true;
    // await recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    // return recorder;
  }

  //some configuration for start record in ios
  Future<void> _handleIOSAudio() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }
}
