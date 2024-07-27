import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/permission_service_handler.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_action_dialog.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_bottom_sheet_upload_media.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/utils/show_add_member_bottom_sheet.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/widgets/add_members_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/widgets/exit_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/info_card_details_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/widgets/group_members_card_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/group_information/widgets/settings_and_media_widget.dart';

class GroupInformationScreen extends BaseStatefulWidget {
  const GroupInformationScreen({super.key});

  @override
  BaseState<GroupInformationScreen> baseCreateState() =>
      _GroupInformationScreenState();
}

class _GroupInformationScreenState extends BaseState<GroupInformationScreen> {
  GroupBloc get _bloc => BlocProvider.of<GroupBloc>(context);
  File? _updatedFile;

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is ShowImagesState) {
          _updatedFile = state.image;
          print("image url: ${state.image.path}");
          hideLoading();
        }
      },
      builder: (context, state) {
        final uid = FirebaseSingleTon.auth.currentUser!.uid;
        //check if admin or not
        bool isAdmin = _bloc.group.adminsUIDS.contains(uid);
        //check if member or not
        bool isMember = _bloc.group.membersUIDS.contains(uid);
        return Scaffold(
          appBar: AppBar(
            title: const Text("Group Information"),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InfoCardDetailsWidget(
                    groupProvider: _bloc,
                    isAdmin: isAdmin,
                    fileImage: _updatedFile,
                    onTapUpdateProfile: () {
                      _openMediaBottomSheet(context);
                    },
                  ),
                  const SizedBox(height: 10),
                  SettingsAndMediaWidget(isAdmin: isAdmin, bloc: _bloc),
                  const SizedBox(height: 20),
                  AddMembers(
                    bloc: _bloc,
                    isAdmin: isAdmin,
                    onTap: () {
                      _bloc.setEmptyTemps();
                      //show bottom sheet to add members
                      showAddMembersBottomSheet(
                        context: context,
                        groupMembersUIDs: _bloc.group.membersUIDS,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  isMember
                      ? Column(
                          children: [
                            GroupMembersCardWidget(
                              isAdmin: isAdmin,
                              bloc: _bloc,
                            ),
                            const SizedBox(height: 10),
                            ExitGroupCardWidget(
                              uid: uid,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //select image
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
              openAppSettings().then(
                (value) async {
                  if (await PermissionServiceHandler().handleServicePermission(
                      setting:
                          PermissionServiceHandler.getCameraPermission())) {
                    // _getImage(ImageSource.camera);
                  }
                },
              );
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
          androidDeviceInfo:
              Platform.isAndroid ? await DeviceInfoPlugin().androidInfo : null,
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
      onTapVideo: () {},
    );
  }

  void _navigateBackEvent() {
    Navigator.pop(context);
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

  Future<void> _getImage(
    ImageSource img,
  ) async {
    final XFile? pickedFile;
    if (img == ImageSource.gallery) {
      final picker = ImagePicker();
      pickedFile = await picker.pickImage(source: img);
      if (pickedFile == null) {
        return;
      }
      _cropperImage(File(pickedFile.path));
    } else {
      final ImagePicker picker = ImagePicker();
      pickedFile = await picker.pickImage(source: img);
      if (pickedFile == null) {
        return;
      }
      XFile? compressedImage = await compressFile(File(pickedFile.path));
      if (compressedImage == null) {
        return;
      }
      _cropperImage(File(compressedImage.path));
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
          viewPort:
              const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    if (croppedFile != null) {
      showLoading();
      _bloc.add(ShowImageEvent(
        image: File(croppedFile.path),
        groupId: _bloc.group.groupID,
      ));
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
}
