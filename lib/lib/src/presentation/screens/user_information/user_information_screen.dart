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
import 'package:rich_chat_copilot/lib/src/presentation/blocs/user_info/user_info_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/user_information/widgets/user_info_body_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/user_information/widgets/user_info_image_widget.dart';

class UserInformationScreen extends BaseStatefulWidget {
  final String phoneNumber;

  const UserInformationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  BaseState<UserInformationScreen> baseCreateState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends BaseState<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();

  UserInfoBloc get _bloc => BlocProvider.of<UserInfoBloc>(context);
  File? _image;

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<UserInfoBloc, UserInfoState>(
        listener: (context, state) {
      if (state is SelectImageState) {
        _cropperImage(state.image);
      } else if (state is ShowImageState) {
        _image = state.image;
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(S.of(context).userInformation),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  UserInfoImageWidget(
                    image: _image,
                    onCameraClicked: () {
                      _openMediaBottomSheet(context);
                    },
                  ),
                  UserInfoBodyWidget(
                    nameController: _nameController,
                    onChanged: (value) {
                      setState(() {
                        _nameController.text = value;
                      });
                    },
                    continuePressed: () {},
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
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
                    setting: PermissionServiceHandler.getCameraPermission())) {}
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
    );
  }

  void _navigateBackEvent() {
    Navigator.pop(context);
  }

  Future<void> _getImage(
    ImageSource img,
  ) async {
    if (img == ImageSource.gallery) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: img);
      if (pickedFile == null) {
        return;
      }
      _bloc.add(SelectImageEvent(File(pickedFile.path)));
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
            toolbarColor: ColorSchemes.primary,
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
        _bloc.add(ShowImageEvent(File(croppedFile.path)));
      }
    }
  }
}
