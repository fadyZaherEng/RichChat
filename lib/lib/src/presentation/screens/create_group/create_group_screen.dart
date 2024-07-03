import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/friend_view_type.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/group_type.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/permission_service_handler.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_action_dialog.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_bottom_sheet_upload_media.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/group/group.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/create_group/widgets/group_type_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/create_group/widgets/setting_list_tile_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/friends_list_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/user_information/widgets/user_info_image_widget.dart';

class CreateGroupScreen extends BaseStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  BaseState<CreateGroupScreen> baseCreateState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends BaseState<CreateGroupScreen> {
  File? _image;
  GroupType groupValue = GroupType.private;

  final _groupNameController = TextEditingController();

  final _groupDescriptionController = TextEditingController();

  GroupBloc get _bloc => BlocProvider.of<GroupBloc>(context);

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            title: Text(
              S.of(context).createGroup,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  child: _bloc.iSLoading
                      ? const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Center(
                            child: IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.white),
                              onPressed: () {
                                //create group
                                _createGroup(context);
                              },
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        UserInfoImageWidget(
                          image: _image,
                          onCameraClicked: () {
                            _openMediaBottomSheet(context);
                          },
                        ),
                        _buildGroupTypeWidget(context),
                      ],
                    ),
                  ),
                  //text field for group name
                  const SizedBox(height: 20),
                  TextField(
                    controller: _groupNameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    maxLength: 25,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Group Name",
                      label: Text("Group Name"),
                      counterText: "",
                    ),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 10),
                  //text field for group description
                  TextField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    controller: _groupDescriptionController,
                    maxLength: 25,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Group Description",
                      label: Text("Group Description"),
                      counterText: "",
                    ),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.zero,
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SettingListTileWidget(
                        title: "Group Settings",
                        icon: Icons.settings,
                        iconColor: Colors.deepPurple,
                        onTap: () {
                          //navigate to group settings
                          Navigator.of(context)
                              .pushNamed(Routes.settingsGroupScreen);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Select Group Members",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  //ios search text field
                  CupertinoSearchTextField(
                    placeholder: "Search",
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    onChanged: (value) {},
                  ),
                   const FriendsListWidget(
                    friendViewType: FriendViewType.friendRequest,
                     groupId: "",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openMediaBottomSheet(BuildContext context) async {
    await showBottomSheetUploadMedia(
        context: context,
        onTapCamera: () async {
          _navigateBackEvent();
          if (await PermissionServiceHandler().handleServicePermission(
              setting: PermissionServiceHandler.getCameraPermission())) {
            _getImage(ImageSource.camera);
          } else {
            _showActionDialog(
              icon: ImagePaths.icCancel,
              onPrimaryAction: () {
                _navigateBackEvent();
                openAppSettings().then((value) async {
                  if (await PermissionServiceHandler().handleServicePermission(
                      setting:
                          PermissionServiceHandler.getCameraPermission())) {}
                });
              },
              onSecondaryAction: () {
                _navigateBackEvent();
              },
              primaryText: S.of(context).ok,
              secondaryText: S.of(context).cancel,
              text: S.of(context).youShouldHaveCameraPermission,
            );
          }
        },
        onTapGallery: () async {
          _navigateBackEvent();
          Permission permission = PermissionServiceHandler.getGalleryPermission(
            true,
            androidDeviceInfo: Platform.isAndroid
                ? await DeviceInfoPlugin().androidInfo
                : null,
          );
          if (await PermissionServiceHandler()
              .handleServicePermission(setting: permission)) {
            _getImage(ImageSource.gallery);
          } else {
            _showActionDialog(
              icon: ImagePaths.icCancel,
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
              primaryText: S.of(context).ok,
              secondaryText: S.of(context).cancel,
              text: S.of(context).youShouldHaveGalleryPermission,
            );
          }
        },
        onTapVideo: () {});
  }

  void _navigateBackEvent() {
    Navigator.pop(context);
  }

  Future<void> _getImage(
    ImageSource img,
  ) async {
    showLoading();
    if (img == ImageSource.gallery) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: img);
      if (pickedFile == null) {
        return;
      }
      // _bloc.add(SelectImageEvent(File(pickedFile.path)));
    } else {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: img);
      if (pickedFile == null) {
        return;
      }
      XFile? compressedImage = await compressFile(File(pickedFile.path));
      if (compressedImage == null) {
        return;
      }
      _cropperImage(File(compressedImage.path));
      // _bloc.add(SelectImageEvent(File(compressedImage.path)));
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
    if (imagePicker != null) {
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
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        _image = File(croppedFile.path);
        // _bloc.add(ShowImageEvent(File(croppedFile.path)));
      }
    }
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

  Widget _buildGroupTypeWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeWidget(
            title: GroupType.private.name,
            value: GroupType.private,
            onChanged: (value) {
              setState(() {
                groupValue = value;
              });
            },
            groupValue: groupValue,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeWidget(
            title: GroupType.public.name,
            value: GroupType.public,
            onChanged: (value) {
              setState(() {
                groupValue = value;
              });
            },
            groupValue: groupValue,
          ),
        ),
      ],
    );
  }

  void _createGroup(BuildContext context) {
    if (_groupNameController.text.isEmpty ||
        _groupNameController.text.length < 3) {
      CustomSnackBarWidget.show(
        context: context,
        message: "Group name must be at least 3 characters long",
        path: ImagePaths.icCancel,
        backgroundColor: ColorSchemes.red,
      );
      return;
    }

    if (_groupDescriptionController.text.isEmpty) {
      CustomSnackBarWidget.show(
        context: context,
        message: "Group description must be at least 3 characters long",
        path: ImagePaths.icCancel,
        backgroundColor: ColorSchemes.red,
      );
      return;
    }
    // if(_image == null){
    //   CustomSnackBarWidget.show(context: context,
    //     message: "Group image must not be empty",
    //     path: ImagePaths.icCancel,
    //     backgroundColor: ColorSchemes.red,
    //   );
    //   return;
    // }
    //get the current user id
    String userId = FirebaseAuth.instance.currentUser!.uid;
    Group group = Group(
      creatorUID: userId,
      groupName: _groupNameController.text.trim(),
      groupDescription: _groupDescriptionController.text.trim(),
      groupID: "",
      groupLogo: "",
      lastMessage: "",
      senderUID: "",
      timeSent: DateTime.now(),
      createAt: DateTime.now(),
      massageType: MassageType.text,
      massageID: "",
      isPrivate: groupValue == GroupType.private,
      editSettings: true,
      approveMembers: false,
      lockMassages: false,
      requestToJoin: false,
      membersUIDS: [],
      adminsUIDS: [],
      awaitingApprovalUIDS: [],
    );
    //create group
    _bloc.createGroup(
      newGroup: group,
      image: _image,
      onSuccess: () {
        CustomSnackBarWidget.show(
          context: context,
          message: "Group created successfully",
          path: ImagePaths.icSuccess,
          backgroundColor: ColorSchemes.green,
        );
        Navigator.pop(context);
      },
      onError: (error) {
        CustomSnackBarWidget.show(
          context: context,
          message: error,
          path: ImagePaths.icCancel,
          backgroundColor: ColorSchemes.red,
        );
      },
    );
  }
}
