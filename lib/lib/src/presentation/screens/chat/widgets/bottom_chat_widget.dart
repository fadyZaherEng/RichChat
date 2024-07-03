import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage_reply.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/massage_reply_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/chat/widgets/record_audio_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';

class BottomChatWidget extends StatefulWidget {
  final String friendName;
  final String friendImage;
  final String friendId;
  final String groupId;
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

  //emoji tap
  final void Function() toggleEmojiKeyWordContainer;
  final bool isShowEmojiPicker;
  final void Function(Category?, Emoji?) emojiSelected;
  final void Function() onBackspacePressed;
  final void Function() hideEmojiContainer;

  BottomChatWidget({
    super.key,
    required this.friendName,
    required this.friendImage,
    required this.friendId,
    required this.groupId,
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
  @override
  Widget build(BuildContext context) {
    if (widget.groupId.isNotEmpty) {
      return _buildLockedMessage();
    }
    return _buildBottomChatWidget(context);
  }

  Widget _buildLockedMessage() {
    //get uid
    final uid = FirebaseSingleTon.auth.currentUser!.uid;
    //get GroupBloc
    final groupProvider = BlocProvider.of<GroupBloc>(context);
    //check if admin
    final isAdmin = groupProvider.group.adminsUIDS.contains(uid);
    //check if member
    final isMember = groupProvider.group.membersUIDS.contains(uid);
    //check if locked
    final isLocked = groupProvider.group.lockMassages;

    return isAdmin
        ? _buildBottomChatWidget(context)
        : isMember
            ? _buildMemberWidget(isLocked)
            : SizedBox(
                height: 60,
              child: Center(
                child: InkWell(
                    onTap: ()async {
                      //send request to join
                    await groupProvider.sendRequestToJoinGroup(
                        groupId: groupProvider.group.groupID,
                        groupName: groupProvider.group.groupName,
                        groupImage: groupProvider.group.groupLogo,
                        uid: uid,
                      ).whenComplete(() {
                        CustomSnackBarWidget.show(
                          context: context,
                          message: "Request Sent",
                          path: ImagePaths.icSuccess,
                          backgroundColor: ColorSchemes.green,
                        );
                      });
                    },
                    child: const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          "you are not member of this group,\n click here to send request to join",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
              ),
            );
  }

  Widget _buildMemberWidget(bool isLocked) {
    return isLocked
        ? const SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "this group is locked,only admin can send messages",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          )
        : _buildBottomChatWidget(context);
  }

  Widget _buildBottomChatWidget(context) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            widget.massageReply != null
                ? MassageReplyWidget(
                    massageReply: widget.massageReply!,
                    setReplyMessageWithNull: widget.setReplyMessageWithNull,
                  )
                : const SizedBox.shrink(),
            Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.41),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                // color: ColorSchemes.white,
                border: Border(
                  top: widget.massageReply != null
                      ? BorderSide.none
                      : BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                  left:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  right:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  bottom:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
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
                          child: LoadingAnimationWidget.threeArchedCircle(
                              color: Theme.of(context).colorScheme.primary,
                              size: 35))
                      : IconButton(
                          onPressed: widget.onAttachPressed,
                          icon: const Icon(Icons.attachment, size: 20)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        onTap: () {
                          widget.hideEmojiContainer();
                        },
                        controller: widget.textEditingController,
                        focusNode: widget.focusNode,
                        //how to expand with text increase problem
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 1,
                        onChanged: (value) {
                          widget.onTextChange(value);
                          setState(() {
                            widget.isShowSendButton = value.isNotEmpty;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                  ),
                  widget.isSendingLoading
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: LoadingAnimationWidget.threeArchedCircle(
                            color: Theme.of(context).colorScheme.primary,
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
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color: Theme.of(context).cardColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          : RecordVoiceWidget(
                              onSendAudio: ({
                                required audioFile,
                                required isSendingButtonShow,
                              }) {
                                setState(() {
                                  widget.isShowSendButton = isSendingButtonShow;
                                });
                                widget.onSendAudioPressed(
                                  audioFile: audioFile,
                                  isSendingButtonShow: isSendingButtonShow,
                                );
                              },
                            ),
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
}
