// ignore_for_file: avoid_print

import 'dart:io';
import 'package:city_eye/generated/l10n.dart';
import 'package:city_eye/src/config/theme/color_schemes.dart';
import 'package:city_eye/src/core/base/widget/base_stateful_widget.dart';
import 'package:city_eye/src/core/resources/image_paths.dart';
import 'package:city_eye/src/core/utils/constants.dart';
import 'package:city_eye/src/core/utils/massage_type.dart';
import 'package:city_eye/src/core/utils/permission_service_handler.dart';
import 'package:city_eye/src/core/utils/show_action_dialog_widget.dart';
import 'package:city_eye/src/core/utils/show_bottom_sheet_upload_media.dart';
import 'package:city_eye/src/core/utils/show_snack_bar.dart';
import 'package:city_eye/src/di/data_layer_injector.dart';
import 'package:city_eye/src/domain/entities/chat/massage.dart';
import 'package:city_eye/src/domain/entities/chat/massage_reply.dart';
import 'package:city_eye/src/domain/entities/sign_in/user.dart';
import 'package:city_eye/src/domain/entities/sign_in/user_unit.dart';
import 'package:city_eye/src/domain/usecase/get_user_information_use_case.dart';
import 'package:city_eye/src/domain/usecase/get_user_unit_use_case.dart';
import 'package:city_eye/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:city_eye/src/presentation/screens/chats/utils/show_delete_bottom_sheet.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/bottom_chat_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/chats_list_massages_widget.dart';
import 'package:city_eye/src/presentation/screens/chats/widgets/chat_app_bar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends BaseStatefulWidget {
  const ChatScreen({super.key});

  @override
  BaseState<ChatScreen> baseCreateState() => _ChatScreenState();
}
//there are some bugs
//1-scroll to bottom  is fixed
//2-voice wave
//3-add massage key to replay massge to scroll

class _ChatScreenState extends BaseState<ChatScreen> {
  final TextEditingController _massageController = TextEditingController();
  final ScrollController _massagesScrollController = ScrollController();
  final FocusNode _massageFocusNode = FocusNode();

  ChatsBloc get _bloc => BlocProvider.of<ChatsBloc>(context);
  User _currentUser = const User();

  //sounds and send button
  bool _isShowSendButton = false;

  //emoji picker
  bool _isShowEmojiPicker = false;
  UserUnit _userUnit = const UserUnit();

  @override
  void initState() {
    super.initState();
    _currentUser = GetUserInformationUseCase(injector())();
    _userUnit = GetUserUnitUseCase(injector())();
  }

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<ChatsBloc, ChatsState>(
      listener: (context, state) {
        if (state is SendTextMessageSuccess) {
          _massageController.clear();
          _bloc.setMassageReply(null);
          _massageFocusNode.requestFocus();
          _isShowSendButton = false;
        }
        if (state is SendTextMessageError) {
          showSnackBar(
            context: context,
            message: state.message,
            color: ColorSchemes.snackBarError,
            icon: ImagePaths.error,
          );
          _isShowSendButton = false;
        } else if (state is SelectImageState) {
          _cropperImage(state.file);
        }else if(state is SendFileMessageLoading) {
            // showLoading();
          }else if (state is SendFileMessageSuccess) {
          _massageController.clear();
          _bloc.setMassageReply(null);
          _massageFocusNode.requestFocus();
          // hideLoading();
        } else if (state is SendFileMessageError) {
          showSnackBar(
            context: context,
            message: state.message,
            color: ColorSchemes.snackBarError,
            icon: ImagePaths.error,
          );
          // hideLoading();
        } else if (state is SelectVideoFromGalleryState) {
          _sendFileMassage(
            massageType: MassageType.video,
            filePath: state.file.path,
          );
        } else if (state is DeleteMassageSuccess) {
          hideLoading();
        } else if (state is DeleteMassageError) {
          showSnackBar(
            context: context,
            message: state.message,
            color: ColorSchemes.snackBarError,
            icon: ImagePaths.error,
          );
          hideLoading();
        } else if (state is DeleteMassageLoading) {
          showLoading();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        ChatAppBar(
                          compoundName: _userUnit.compoundName,
                          compoundLogo: _userUnit.compoundLogo,
                          subscriberName: _currentUser.userInformation.name,
                          onTapImageProfile: (image) {},
                          onTapBackArrow: () {
                            _navigateBackEvent();
                          },
                        ),
                        Expanded(
                          child: ChatsListMassagesWidget(
                            massagesStream: _bloc.getMessagesStream(
                              subscriberId: _userUnit.subscriberId,
                              compoundId: _userUnit.compoundId,
                            ),
                            setMassageReplyNull: () {
                              _scrollToBottom();
                              _bloc.setMassageReply(null);
                            },
                            subscriberId: _userUnit.subscriberId,
                            compoundId: _userUnit.compoundId,
                            massagesScrollController: _massagesScrollController,
                            currentUser: _currentUser,
                            onRightSwipe: (MassageReply massageReply) {
                              _bloc.setMassageReply(massageReply);
                            },
                            showEmojiKeyword: (massage) {
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                _navigateBackEvent();
                                _showEmojiPickerDialog(massage);
                              });
                            },
                            onEmojiSelected: (String emoji, Massage massage) {
                              if (emoji == '➕') {
                                // Future.delayed(const Duration(milliseconds: 500), () {
                                //   _navigateBackEvent();
                                // });
                                //show emoji keyword
                                _showEmojiPickerDialog(massage);
                              } else {
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  _navigateBackEvent();
                                });
                                _bloc.add(SelectReactionEvent(
                                  massageId: massage.messageId,
                                  senderId: _currentUser.userInformation.id
                                      .toString(),
                                  reaction: emoji,
                                  compoundId: _userUnit.compoundId,
                                  subscriberId: _userUnit.subscriberId,
                                ));
                              }
                            },
                            onContextMenuSelected:
                                (String contextMenu, Massage massage) {
                              // Future.delayed(const Duration(milliseconds: 500), () {
                              //   _navigateBackEvent();
                              // });
                              _onContextMenuSelected(
                                contextMenu: contextMenu,
                                massage: massage,
                                state: state,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        BottomChatWidget(
                          textEditingController: _massageController,
                          focusNode: _massageFocusNode,
                          isAttachedLoading: state is SendFileMessageLoading,
                          isSendingLoading: state is SendTextMessageLoading,
                          isShowSendButton: _isShowSendButton,
                          hideEmojiContainer: () {
                            _hideEmojiContainer();
                            _scrollToBottom();
                          },
                          emojiSelected: (category, emoji) {
                            _massageController.text =
                                _massageController.text + emoji!.emoji;
                            if (!_isShowSendButton) {
                              setState(() {
                                _isShowSendButton = true;
                              });
                            }
                          },
                          isShowEmojiPicker: _isShowEmojiPicker,
                          onBackspacePressed: () {},
                          toggleEmojiKeyWordContainer: () {
                            _toggleEmojiKeyWordContainer();
                            _scrollToBottom();
                          },
                          onTextChange: (String value) {
                            _isShowSendButton = value.isNotEmpty;
                            // _scrollToBottom();
                            _massageController.text = value;
                          },
                          onAttachPressed: () {
                            _scrollToBottom();
                            _openMediaBottomSheet(context);
                          },
                          onSendTextPressed: () {
                            _scrollToBottom();
                            if (_massageController.text.isNotEmpty) {
                              _bloc.add(SendTextMessageEvent(
                                sender: _currentUser,
                                receiverId: _userUnit.compoundId,
                                message: _massageController.text,
                                massageType: MassageType.text,
                                subscriberId: _userUnit.subscriberId,
                                compoundId: _userUnit.compoundId,
                              ));
                            }
                          },
                          massageReply: _bloc.massageReply,
                          setReplyMessageWithNull: () {
                            _scrollToBottom();
                            _bloc.setMassageReply(null);
                          },
                          onSendAudioPressed: ({
                            required File audioFile,
                            required bool isSendingButtonShow,
                          }) {
                            _scrollToBottom();
                            _isShowSendButton = isSendingButtonShow;
                            _sendFileMassage(
                              massageType: MassageType.audio,
                              filePath: audioFile.path,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    _massagesScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _hideEmojiContainer() {
    _isShowEmojiPicker = false;
    _isShowSendButton = false;
    if (_massageController.text.isNotEmpty) {
      _isShowSendButton = true;
    }
    setState(() {});
  }

  void _showEmojiContainer() {
    setState(() {
      _isShowEmojiPicker = true;
      _isShowSendButton = true;
    });
  }

  void _showKeyWord() {
    _massageFocusNode.requestFocus();
  }

  void _hideKeyWord() {
    _massageFocusNode.unfocus();
  }

  void _toggleEmojiKeyWordContainer() {
    if (_isShowEmojiPicker) {
      _showKeyWord();
      _hideEmojiContainer();
    } else {
      _hideKeyWord();
      _showEmojiContainer();
    }
  }

  //show emoji container
  void _showEmojiPickerDialog(Massage massage) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: EmojiPicker(
            onEmojiSelected: (category, Emoji emoji) {
              _navigateBackEvent();
              //add emoji to message
              _bloc.add(SelectReactionEvent(
                massageId: massage.messageId,
                senderId: _currentUser.userInformation.id.toString(),
                reaction: emoji.emoji,
                compoundId: _userUnit.compoundId,
                subscriberId: _userUnit.subscriberId,
              ));
              Future.delayed(const Duration(milliseconds: 300), () {
                _navigateBackEvent();
              });
            },
          ),
        );
      },
    );
  }

  //send image and video
  void _openMediaBottomSheet(BuildContext context) async {
    await showBottomSheetUploadMedia(
      context: context,
      onTapCamera: () async {
        _navigateBackEvent();
        if (await PermissionServiceHandler().handleServicePermission(
            setting: PermissionServiceHandler.getCameraPermission())) {
          _getMedia(
            imageSource: ImageSource.camera,
            massageType: MassageType.image,
          );
        } else {
          _showActionDialog(
            icon: ImagePaths.cancelRate,
            onPrimaryAction: () {
              _navigateBackEvent();
              openAppSettings().then((value) async {
                if (await PermissionServiceHandler().handleServicePermission(
                    setting: PermissionServiceHandler.getCameraPermission())) {}
              });
            },
            onSecondaryAction: () {
              _navigateBackEvent();
            },
            primaryText: S.current.ok,
            secondaryText: S.current.cancel,
            text: S.current.youShouldHaveCameraPermission,
          );
        }
      },
      onTapGallery: () async {
        _navigateBackEvent();
        Permission permission = PermissionServiceHandler.getGalleryPermission(
          true,
          androidDeviceInfo:
              Platform.isAndroid ? await DeviceInfoPlugin().androidInfo : null,
        );
        if (await PermissionServiceHandler()
            .handleServicePermission(setting: permission)) {
          _getMedia(
            imageSource: ImageSource.gallery,
            massageType: MassageType.image,
          );
        } else {
          _showActionDialog(
            icon: ImagePaths.cancelRate,
            onPrimaryAction: () {
              _navigateBackEvent();
              openAppSettings().then((value) async {
                if (await PermissionServiceHandler()
                    .handleServicePermission(setting: permission)) {}
              });
            },
            onSecondaryAction: () {
              _navigateBackEvent();
            },
            primaryText: S.current.ok,
            secondaryText: S.current.cancel,
            text: S.current.youShouldHaveMicroPhonePermission,
          );
        }
      },
      onTapVideo: () async {
        //TODO: send video from gallery
        _navigateBackEvent();
        _getMedia(
          imageSource: ImageSource.gallery,
          massageType: MassageType.video,
        );
      },
      isVideo: true,
    );
  }

  void _showActionDialog({
    required String icon,
    required void Function() onPrimaryAction,
    required void Function() onSecondaryAction,
    required String primaryText,
    required String secondaryText,
    required String text,
  }) async {
    await showActionDialogWidget(
      context: context,
      text: text,
      primaryText: primaryText,
      primaryAction: () {
        onPrimaryAction();
      },
      secondaryText: secondaryText,
      secondaryAction: () {
        onSecondaryAction();
      },
      icon: icon,
    );
  }

  Future<void> _getMedia({
    required ImageSource imageSource,
    required MassageType massageType,
  }) async {
    if (imageSource == ImageSource.gallery) {
      if (massageType == MassageType.image) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: imageSource);
        if (pickedFile == null) {
          return;
        }
        _bloc.add(SelectImageEvent(File(pickedFile.path)));
      } else if (massageType == MassageType.video) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickVideo(source: imageSource);
        if (pickedFile == null) {
          return;
        }
        _bloc.add(SelectVideoFromGalleryEvent(File(pickedFile.path)));
      }
    } else {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: imageSource);
      if (pickedFile == null) {
        return;
      }
      XFile? compressedImage = await compressFile(File(pickedFile.path));
      if (compressedImage == null) {
        return;
      }

      _bloc.add(SelectImageEvent(File(compressedImage.path)));
    }
  }

  Future<XFile?> compressFile(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    if (lastIndex == filePath.lastIndexOf(RegExp(r'.png'))) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
          filePath, outPath,
          minWidth: 1000,
          minHeight: 1000,
          quality: 50,
          format: CompressFormat.png);
      return compressedImage;
    } else {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        minWidth: 1000,
        minHeight: 1000,
        quality: 50,
      );
      return compressedImage;
    }
  }

  Future _cropperImage(File imagePicker) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePicker.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      compressQuality: 100,
      cropStyle: CropStyle.rectangle,
      maxWidth: 1080,
      maxHeight: 1080,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: ColorSchemes.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Cropper'),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(width: 520, height: 520),
          viewPort: const CroppieViewPort(width: 480, height: 480),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    if (croppedFile != null) {
      _sendFileMassage(
        massageType: MassageType.image,
        filePath: croppedFile.path,
      );
    }
  }

  //send file massage
  void _sendFileMassage({
    required MassageType massageType,
    required String filePath,
  }) {
    _bloc.add(
      SendFileMessageEvent(
        sender: _currentUser,
        file: File(filePath),
        massageType: massageType,
        compoundId: _userUnit.compoundId,
        compoundImage: _userUnit.compoundLogo,
        compoundName: _userUnit.compoundName,
        subscriberId: _userUnit.subscriberId,
      ),
    );
  }

  void _navigateBackEvent() {
    Navigator.of(context).pop();
  }

  void _onContextMenuSelected({
    required String contextMenu,
    required Massage massage,
    required ChatsState state,
  }) {
    switch (contextMenu) {
      case Constants.delete:
        if (massage.senderId == _currentUser.userInformation.id) {
          showDeleteBottomSheet(
              isSender: true,
              context: context,
              isLoading: state is DeleteMassageLoading,
              onDelete: ({
                required bool deleteForEveryoneOrNot,
              }) {
                _bloc.add(DeleteMassageEvent(
                  messageId: massage.messageId,
                  messageType: massage.massageType.name,
                  deleteForEveryone: deleteForEveryoneOrNot,
                  compoundId: _userUnit.compoundId,
                  subscriberId: _userUnit.subscriberId,
                  currentUserId: _currentUser.userInformation.id,
                ));
              });
        } else {
          showDeleteBottomSheet(
              isSender: false,
              context: context,
              isLoading: state is DeleteMassageLoading,
              onDelete: ({
                required bool deleteForEveryoneOrNot,
              }) {
                _bloc.add(DeleteMassageEvent(
                  messageId: massage.messageId,
                  messageType: massage.massageType.name,
                  deleteForEveryone: deleteForEveryoneOrNot,
                  compoundId: _userUnit.compoundId,
                  subscriberId: _userUnit.subscriberId,
                  currentUserId: _currentUser.userInformation.id,
                ));
              });
        }
        break;
      case Constants.reply:
        final massageReply = MassageReply(
          massage: massage.massage,
          senderName: massage.senderName,
          senderId: massage.senderId.toString(),
          senderImage: massage.senderImage,
          massageType: massage.massageType,
          isMe: true,
        );
        _bloc.setMassageReply(massageReply);
        Navigator.of(context).pop();
        break;
      case Constants.copy:
        Clipboard.setData(ClipboardData(text: massage.massage));
        showSnackBar(
          context: context,
          message: S.of(context).copied,
          color: ColorSchemes.green,
          icon: ImagePaths.success,
        );
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _massageController.dispose();
    _massagesScrollController.dispose();
    _massageFocusNode.dispose();
    super.dispose();
  }
}
