import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:city_eye/generated/l10n.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:city_eye/src/core/utils/permission_service_handler.dart';
import 'package:city_eye/src/core/utils/show_action_dialog_widget.dart';
import 'package:city_eye/src/domain/entities/chat/massage_reply.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/massage_reply_preview_widget.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomChatWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function() onSendTextPressed;
  final void Function({
    required File audioFile,
    required bool isSendingButtonShow,
  }) onSendAudioPressed;
  final Function() onAttachPressed;
  final Function(String) onTextChange;
  final FocusNode focusNode;
  final MassageReply? massageReply;
  final Function() setReplyMessageWithNull;
  final bool isAttachedLoading;
  final bool isSendingLoading;
  bool isShowSendButton;

  //emoji properties
  final void Function() toggleEmojiKeyWordContainer;
  final bool isShowEmojiPicker;
  final void Function(Category?, Emoji?) emojiSelected;
  final void Function() onBackspacePressed;
  final void Function() hideEmojiContainer;

  BottomChatWidget({
    super.key,
    required this.textEditingController,
    required this.onSendTextPressed,
    required this.onSendAudioPressed,
    required this.onAttachPressed,
    required this.focusNode,
    required this.onTextChange,
    required this.massageReply,
    required this.setReplyMessageWithNull,
    required this.isAttachedLoading,
    required this.isSendingLoading,
    required this.isShowSendButton,
    required this.toggleEmojiKeyWordContainer,
    required this.isShowEmojiPicker,
    required this.emojiSelected,
    required this.onBackspacePressed,
    required this.hideEmojiContainer,
  });

  @override
  State<BottomChatWidget> createState() => _BottomChatWidgetState();
}

class _BottomChatWidgetState extends State<BottomChatWidget> {
  late final RecorderController recorderController;
  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory;

  @override
  void initState() {
    super.initState();
    _getDir();
    _initialiseControllers();
  }

  void _getDir() async {
    if (Platform.isIOS) {
      appDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDirectory = await getApplicationDocumentsDirectory();
    }
    path = "${appDirectory.path}/recording.m4a";
    isLoading = false;
    setState(() {});
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            widget.massageReply != null
                ? MassageReplyPreviewWidget(
                    massageReply: widget.massageReply!,
                    setReplyMessageWithNull: widget.setReplyMessageWithNull,
                    isShowCloseButton: true,
                  )
                : const SizedBox.shrink(),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.41,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                // color: ColorSchemes.white,
                border: Border(
                  top: widget.massageReply != null
                      ? BorderSide.none
                      : BorderSide(color: ColorSchemes.primary),
                  left: BorderSide(color: ColorSchemes.primary),
                  right: BorderSide(color: ColorSchemes.primary),
                  bottom: BorderSide(color: ColorSchemes.primary),
                ),
                borderRadius: widget.massageReply != null
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: isRecording
                        ? Row(
                            children: [
                              Expanded(
                                child: AudioWaveforms(
                                  enableGesture: true,
                                  size: Size(
                                      MediaQuery.of(context).size.width * 0.8,
                                      50),
                                  recorderController: recorderController,
                                  waveStyle: WaveStyle(
                                    waveColor: ColorSchemes.primary,
                                    extendWaveform: true,
                                    showMiddleLine: false,
                                    scaleFactor: 20,
                                    durationLinesHeight: 10,
                                    labelSpacing: 12,
                                    waveThickness: 4,
                                    spacing: 8,
                                    waveCap: StrokeCap.round,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  padding: const EdgeInsets.only(left: 18),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                ),
                              ),
                              IconButton(
                                onPressed: _refreshWave,
                                icon: Icon(
                                  Icons.refresh,
                                  color: ColorSchemes.primary,
                                ),
                              ),
                              // const SizedBox(width: 16),
                              // InkWell(
                              //   onTap: ()async {
                              //     //stop recording
                              //     await recorderController.stop();
                              //     setState(() {
                              //       isRecording = false;
                              //     });
                              //   },
                              //   child: Container(
                              //     margin: const EdgeInsets.symmetric(vertical: 8),
                              //     width: 35,
                              //     height: 35,
                              //     decoration: BoxDecoration(
                              //       color: ColorSchemes.primary,
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),
                              //     child: Center(
                              //       child: Icon(
                              //         Icons.stop,
                              //         color: ColorSchemes.iconBackGround,
                              //         weight: 20,
                              //         size: 20,
                              //       )
                              //     ),
                              //   ),
                              // )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //emoji widget
                              IconButton(
                                onPressed: widget.toggleEmojiKeyWordContainer,
                                icon: Icon(
                                  widget.isShowEmojiPicker
                                      ? Icons.keyboard
                                      : Icons.emoji_emotions_outlined,
                                  size: 20,
                                ),
                              ),
                              widget.isAttachedLoading
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: LoadingAnimationWidget
                                          .threeArchedCircle(
                                        color: ColorSchemes.primary,
                                        size: 35,
                                      ))
                                  : IconButton(
                                      onPressed: widget.onAttachPressed,
                                      icon: const Icon(
                                        Icons.attachment,
                                        size: 20,
                                      ),
                                    ),
                              isRecording
                                  ? const SizedBox.shrink()
                                  : Expanded(
                                      child: SingleChildScrollView(
                                        child: TextField(
                                          onTap: () {
                                            widget.hideEmojiContainer();
                                          },
                                          controller:
                                              widget.textEditingController,
                                          focusNode: widget.focusNode,
                                          //how to expand with text increase problem
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          minLines: 1,
                                          onChanged: (value) {
                                            widget.onTextChange(value);
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                S.of(context).typeAMessage,
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                              // IconButton(
                              //   onPressed: _requestMicrophonePermission,
                              //   icon: const Icon(Icons.stop),
                              //   color: Colors.white,
                              //   iconSize: 28,
                              // )

                              // RecordVoiceWidget(
                              //             onSendAudio: ({
                              //               required audioFile,
                              //               required isSendingButtonShow,
                              //             }) {
                              //               setState(() {
                              //                 widget.isShowSendButton = isSendingButtonShow;
                              //               });
                              //               widget.onSendAudioPressed(
                              //                 audioFile: audioFile,
                              //                 isSendingButtonShow: isSendingButtonShow,
                              //               );
                              //             },
                              //             flutterSoundRecord: _soundRecorder,
                              //           ),
                            ],
                          ),
                  ),
                  widget.isSendingLoading
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: LoadingAnimationWidget.threeArchedCircle(
                            color: ColorSchemes.primary,
                            size: 25,
                          ),
                        )
                      : widget.isShowSendButton
                          ? GestureDetector(
                              onTap: widget.onSendTextPressed,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: ColorSchemes.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color: ColorSchemes.iconBackGround,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onLongPress: () async {
                                _requestMicrophonePermission();
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
                                  child: isRecording
                                      ? InkWell(
                                          onTap: _stopRecording,
                                          child: Icon(
                                            Icons.stop,
                                            color: ColorSchemes.iconBackGround,
                                            size: 20,
                                            weight: 20,
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          ImagePaths.microphone,
                                          fit: BoxFit.scaleDown,
                                          width: 20,
                                          height: 20,
                                          color: ColorSchemes.iconBackGround,
                                        ),
                                ),
                              ),
                            )
                ],
              ),
            ),
            //show emoji container
            widget.isShowEmojiPicker
                ? SizedBox(
                    height: 200,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        widget.emojiSelected(category, emoji);
                      },
                      onBackspacePressed: widget.onBackspacePressed,
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Future _requestMicrophonePermission() async {
    if (await PermissionServiceHandler().handleServicePermission(
      setting: Permission.microphone,
    )) {
      await initRecorder();
      await _startRecording();
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

  Future<void> _startRecording() async {
    try {
      if (isRecording) return;
      setState(() {
        isRecording = true;
      });
      if (await recorderController.checkPermission()) {
        await recorderController.record(path: path); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _stopRecording() async {
    String? record = await recorderController.stop();

    setState(() {
      isRecording = false;
    });
    if (record == null) return;
    path = record;
    widget.onSendAudioPressed(
      audioFile: File(path ?? ""),
      isSendingButtonShow: false,
    );
    if (path != null) {
      isRecordingCompleted = true;
      debugPrint(path);
      debugPrint("Recorded file size: ${File(path!).lengthSync()}");
    }
    _refreshWave();
    path = null;
  }

  void _refreshWave() {
    if (isRecording) recorderController.refresh();
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }
}

// class BottomChatWidget extends StatefulWidget {
//   final TextEditingController textEditingController;
//   final Function() onSendTextPressed;
//   final void Function({
//   required File audioFile,
//   required bool isSendingButtonShow,
//   }) onSendAudioPressed;
//   final Function() onAttachPressed;
//   final Function(String) onTextChange;
//   final FocusNode focusNode;
//   final MassageReply? massageReply;
//   final Function() setReplyMessageWithNull;
//   final bool isAttachedLoading;
//   final bool isSendingLoading;
//   bool isShowSendButton;
//
//   //emoji properties
//   final void Function() toggleEmojiKeyWordContainer;
//   final bool isShowEmojiPicker;
//   final void Function(Category?, Emoji?) emojiSelected;
//   final void Function() onBackspacePressed;
//   final void Function() hideEmojiContainer;
//
//   BottomChatWidget({
//     super.key,
//     required this.textEditingController,
//     required this.onSendTextPressed,
//     required this.onSendAudioPressed,
//     required this.onAttachPressed,
//     required this.focusNode,
//     required this.onTextChange,
//     required this.massageReply,
//     required this.setReplyMessageWithNull,
//     required this.isAttachedLoading,
//     required this.isSendingLoading,
//     required this.isShowSendButton,
//     required this.toggleEmojiKeyWordContainer,
//     required this.isShowEmojiPicker,
//     required this.emojiSelected,
//     required this.onBackspacePressed,
//     required this.hideEmojiContainer,
//   });
//
//   @override
//   State<BottomChatWidget> createState() => _BottomChatWidgetState();
// }
//
// class _BottomChatWidgetState extends State<BottomChatWidget> {
//   late FlutterSoundRecord  _soundRecorder;
//
//   @override
//   void initState() {
//     _soundRecorder = FlutterSoundRecord();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return IntrinsicHeight(
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           children: [
//             widget.massageReply != null
//                 ? MassageReplyPreviewWidget(
//               massageReply: widget.massageReply!,
//               setReplyMessageWithNull: widget.setReplyMessageWithNull,
//             )
//                 : const SizedBox.shrink(),
//             Container(
//               constraints: BoxConstraints(
//                 maxHeight: MediaQuery.of(context).size.height * 0.37,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 // color: ColorSchemes.white,
//                 border: Border(
//                   top: widget.massageReply != null
//                       ? BorderSide.none
//                       : BorderSide(color: ColorSchemes.primary),
//                   left: BorderSide(color: ColorSchemes.primary),
//                   right: BorderSide(color: ColorSchemes.primary),
//                   bottom: BorderSide(color: ColorSchemes.primary),
//                 ),
//                 borderRadius: widget.massageReply != null
//                     ? const BorderRadius.only(
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30))
//                     : const BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                   bottomLeft: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   //emoji widget
//                   IconButton(
//                     onPressed: widget.toggleEmojiKeyWordContainer,
//                     icon: Icon(
//                       widget.isShowEmojiPicker
//                           ? Icons.keyboard
//                           : Icons.emoji_emotions_outlined,
//                       size: 20,
//                     ),
//                   ),
//                   widget.isAttachedLoading
//                       ? Padding(
//                       padding: const EdgeInsets.only(top: 5),
//                       child: LoadingAnimationWidget.threeArchedCircle(
//                         color: ColorSchemes.primary,
//                         size: 35,
//                       ))
//                       : IconButton(
//                       onPressed: widget.onAttachPressed,
//                       icon: const Icon(Icons.attachment, size: 20)),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: TextField(
//                         onTap: () {
//                           widget.hideEmojiContainer();
//                         },
//                         controller: widget.textEditingController,
//                         focusNode: widget.focusNode,
//                         //how to expand with text increase problem
//                         keyboardType: TextInputType.multiline,
//                         maxLines: null,
//                         minLines: 1,
//                         onChanged: (value) {
//                           widget.onTextChange(value);
//                         },
//                         decoration: InputDecoration(
//                           hintText: S.of(context).typeAMessage,
//                           border: InputBorder.none,
//                           enabledBorder: InputBorder.none,
//                           focusedBorder: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   widget.isSendingLoading
//                       ? Padding(
//                     padding: const EdgeInsets.only(top: 10),
//                     child: LoadingAnimationWidget.threeArchedCircle(
//                       color: ColorSchemes.primary,
//                       size: 25,
//                     ),
//                   )
//                       : widget.isShowSendButton
//                       ? GestureDetector(
//                     onTap: widget.onSendTextPressed,
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       width: 35,
//                       height: 35,
//                       decoration: BoxDecoration(
//                         color: ColorSchemes.primary,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Center(
//                         child: Icon(
//                           Icons.arrow_upward,
//                           color: ColorSchemes.iconBackGround,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   )
//                       : RecordVoiceWidget(
//                     onSendAudio: ({
//                       required audioFile,
//                       required isSendingButtonShow,
//                     }) {
//                       setState(() {
//                         widget.isShowSendButton = isSendingButtonShow;
//                       });
//                       widget.onSendAudioPressed(
//                         audioFile: audioFile,
//                         isSendingButtonShow: isSendingButtonShow,
//                       );
//                     },
//                     flutterSoundRecord: _soundRecorder,
//                   ),
//                 ],
//               ),
//             ),
//             //show emoji container
//             widget.isShowEmojiPicker
//                 ? SizedBox(
//               height: 200,
//               child: EmojiPicker(
//                 onEmojiSelected: (category, emoji) {
//                   widget.emojiSelected(category, emoji);
//                 },
//                 onBackspacePressed: widget.onBackspacePressed,
//               ),
//             )
//                 : const SizedBox.shrink()
//           ],
//         ),
//       ),
//     );
//   }
// }
