import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/config/theme/color_schemes.dart';
import 'package:rich_chat_copilot/lib/src/core/base/widget/base_stateful_widget.dart';
import 'package:rich_chat_copilot/lib/src/core/resources/image_paths.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/permission_service_handler.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_action_dialog.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/show_bottom_sheet_upload_media.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_language_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_language_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/profile/profile_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/create_group/widgets/setting_list_tile_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_switch_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/info_card_details_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/build_app_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/custom_snack_bar_widget.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/restart_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends BaseStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  BaseState<ProfileScreen> baseCreateState() => _ProfileScreenState();
}

class _ProfileScreenState extends BaseState<ProfileScreen> {
  UserModel _currentUser = UserModel();
  UserModel _otherUser = UserModel();
  bool isArabic = false;
  bool isDarkMode = false;

  ProfileBloc get _bloc => BlocProvider.of<ProfileBloc>(context);
  File? _updatedFile;

  @override
  void initState() {
    getThemeMode();
    super.initState();
    _currentUser = GetUserUseCase(injector())();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isArabic = GetLanguageUseCase(injector())() == Constants.ar;
  }

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is SendFriendRequestSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).requestSent,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is SendFriendRequestFailed) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Send friend request failed",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        } else if (state is CancelFriendRequestSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).requestCanceled,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is CancelFriendRequestFailed) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Cancel friend request failed",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        } else if (state is AcceptFriendRequestSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).friendRequestAccepted,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is AcceptFriendRequestFailed) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Accept friend request failed",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        } else if (state is UnFriendSuccess) {
          CustomSnackBarWidget.show(
            context: context,
            message: S.of(context).unFriend,
            path: ImagePaths.icSuccess,
            backgroundColor: ColorSchemes.green,
          );
        } else if (state is UnFriendFailed) {
          CustomSnackBarWidget.show(
            context: context,
            message: "Unfriend failed",
            path: ImagePaths.icCancel,
            backgroundColor: ColorSchemes.red,
          );
        } else if (state is ShowImageState) {
          _updatedFile = state.imageUrl;
        } else if (state is SaveGroupImageSuccessInSharedPreferencesState) {
          //TODO: implement save profile image in shared preferences
          _currentUser = _currentUser.copyWith(image: state.image);
          SetUserUseCase(injector())(_currentUser);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: buildAppBarWidget(
            backgroundColor: Theme.of(context).cardColor,
            context,
            title: S.of(context).profile,
            isHaveBackButton: true,
            onBackButtonPressed: () {
              Navigator.pop(context);
            },
          ),
          body: StreamBuilder(
            stream: FirebaseSingleTon.db
                .collection(Constants.users)
                .doc(widget.userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                _otherUser = UserModel.fromJson(snapshot.data!.data()!);
                final isMyProfile =
                    FirebaseSingleTon.auth.currentUser!.uid == _otherUser.uId;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoCardDetailsWidget(
                          userModel: _otherUser,
                          fileImage: _updatedFile,
                          onTapUpdateProfile: () {
                            _openMediaBottomSheet(context);
                          },
                        ),
                        const SizedBox(height: 10),
                        isMyProfile
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      S.of(context).settings,
                                      style: GoogleFonts.openSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAccountAndMediaAndNotificationSettings(),
                                  const SizedBox(height: 10),
                                  _buildHelpAndShareSettings(),
                                  const SizedBox(height: 10),
                                  _buildRestSettings(),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        );
      },
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showActionDialogWidget(
      context: context,
      text: S.of(context).logOut,
      iconData: Icons.logout,
      primaryText: S.of(context).yes,
      secondaryText: S.of(context).no,
      primaryAction: () async {
        //log out
        Navigator.pop(context);
        await FirebaseSingleTon.auth.signOut();
        Navigator.pushReplacementNamed(context, Routes.logInScreen);
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      },
      secondaryAction: () {
        Navigator.pop(context);
      },
    );
  }

  void getThemeMode() async {
    // get the saved theme mode
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    // check if the saved theme mode is dark
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      // set the isDarkMode to true
      setState(() {
        isDarkMode = true;
      });
    } else {
      // set the isDarkMode to false
      setState(() {
        isDarkMode = false;
      });
    }
  }

  Widget _buildAccountAndMediaAndNotificationSettings() {
    return Card(
      child: Column(
        children: [
          SettingListTileWidget(
            title: S.of(context).account,
            icon: Icons.person,
            iconColor: Colors.deepPurple,
            onTap: () {
              // navigate to account settings
            },
          ),
          SettingListTileWidget(
            title: S.of(context).myMedia,
            icon: Icons.image,
            iconColor: Colors.green,
            onTap: () {
              // navigate to account settings
            },
          ),
          SettingListTileWidget(
            title: S.of(context).notifications,
            icon: Icons.notifications,
            iconColor: Colors.red,
            onTap: () {
              // navigate to account settings
              OpenSettings.openAppNotificationSetting();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelpAndShareSettings() {
    return Card(
      child: Column(
        children: [
          SettingListTileWidget(
            title: S.of(context).help,
            icon: Icons.help,
            iconColor: Colors.yellow,
            onTap: () {
              // navigate to help settings
            },
          ),
          SettingListTileWidget(
            title: S.of(context).share,
            icon: Icons.share,
            iconColor: Colors.blue,
            onTap: () {
              // navigate to share settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRestSettings() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Card(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
            title: Text(S.of(context).changeTheme),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                // set the isDarkMode to the value
                setState(() {
                  isDarkMode = value;
                });
                // check if the value is true
                if (value) {
                  // set the theme mode to dark
                  AdaptiveTheme.of(context).setDark();
                } else {
                  // set the theme mode to light
                  AdaptiveTheme.of(context).setLight();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        CustomSwitchWidget(
          value: isArabic,
          onChanged: (bool value) async {
            await SetLanguageUseCase(injector())(
                value ? Constants.ar : Constants.en);
            setState(() {
              isArabic = value;
            });
            Future.delayed(
              const Duration(milliseconds: 300),
              () {
                RestartWidget.restartApp(context);
              },
            );
          },
          title: S.of(context).language,
        ),
        const SizedBox(height: 10),
        //isMe
        _currentUser.uId == widget.userId
            ? const SizedBox.shrink()
            : Card(
                child: Column(
                  children: [
                    SettingListTileWidget(
                      title: S.of(context).logout,
                      icon: Icons.logout_outlined,
                      iconColor: Colors.red,
                      onTap: () {
                        //TODO: logout
                        _showLogOutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
      ],
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
    showLoading();
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
    hideLoading();
    if (croppedFile != null) {
      _bloc.add(ShowImageEvent(File(croppedFile.path)));
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
