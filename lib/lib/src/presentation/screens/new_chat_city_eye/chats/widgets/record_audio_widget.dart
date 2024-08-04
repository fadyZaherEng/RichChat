// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use, must_be_immutable
import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:city_eye/generated/l10n.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:city_eye/src/core/utils/permission_service_handler.dart';
import 'package:city_eye/src/core/utils/show_action_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
              color: ColorSchemes.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: SvgPicture.asset(
                      ImagePaths.microphone,
                      fit: BoxFit.scaleDown,
                      width: 20,
                      height: 20,
                      color:ColorSchemes.iconBackGround,
                    ),
            ),
          ),
        ),
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
        text: S.of(context).youShouldHaveMicroPhonePermission,
        icon: ImagePaths.microphone,
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
    isRecorderReady = true;
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
