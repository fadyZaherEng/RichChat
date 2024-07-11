// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Chats`
  String get appTitle {
    return Intl.message(
      'Chats',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'Powered by - Rich Chat' key

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to the Copilot Chatbot. What would you like to chat about?`
  String get welcomeMessage {
    return Intl.message(
      'Welcome to the Copilot Chatbot. What would you like to chat about?',
      name: 'welcomeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Chats`
  String get chats {
    return Intl.message(
      'Chats',
      name: 'chats',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get groups {
    return Intl.message(
      'Groups',
      name: 'groups',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get globes {
    return Intl.message(
      'People',
      name: 'globes',
      desc: '',
      args: [],
    );
  }

  /// `Rich Chat`
  String get richChat {
    return Intl.message(
      'Rich Chat',
      name: 'richChat',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Add your phone number, we'll send you a verification code`
  String get addYourPhoneNumberMessage {
    return Intl.message(
      'Add your phone number, we\'ll send you a verification code',
      name: 'addYourPhoneNumberMessage',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get verification {
    return Intl.message(
      'Verification',
      name: 'verification',
      desc: '',
      args: [],
    );
  }

  /// `Enter the 6 digit code sent to your mobile number`
  String get enterThe6Digit {
    return Intl.message(
      'Enter the 6 digit code sent to your mobile number',
      name: 'enterThe6Digit',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get resendCode {
    return Intl.message(
      'Resend Code',
      name: 'resendCode',
      desc: '',
      args: [],
    );
  }

  /// `Didn't recieve the code`
  String get didReceiveTheCode {
    return Intl.message(
      'Didn\'t recieve the code',
      name: 'didReceiveTheCode',
      desc: '',
      args: [],
    );
  }

  /// `User Information`
  String get userInformation {
    return Intl.message(
      'User Information',
      name: 'userInformation',
      desc: '',
      args: [],
    );
  }

  /// `Enter Name`
  String get enterName {
    return Intl.message(
      'Enter Name',
      name: 'enterName',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continues {
    return Intl.message(
      'Continue',
      name: 'continues',
      desc: '',
      args: [],
    );
  }

  /// `OTP SMS Not Valid`
  String get OTPSMSNotValid {
    return Intl.message(
      'OTP SMS Not Valid',
      name: 'OTPSMSNotValid',
      desc: '',
      args: [],
    );
  }

  /// `Sent to`
  String get sentTo {
    return Intl.message(
      'Sent to',
      name: 'sentTo',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Choose Image`
  String get chooseImage {
    return Intl.message(
      'Choose Image',
      name: 'chooseImage',
      desc: '',
      args: [],
    );
  }

  /// `Upload from Camera`
  String get uploadCamera {
    return Intl.message(
      'Upload from Camera',
      name: 'uploadCamera',
      desc: '',
      args: [],
    );
  }

  /// `Upload from Gallery`
  String get uploadGallery {
    return Intl.message(
      'Upload from Gallery',
      name: 'uploadGallery',
      desc: '',
      args: [],
    );
  }

  /// `Choose File`
  String get chooseFile {
    return Intl.message(
      'Choose File',
      name: 'chooseFile',
      desc: '',
      args: [],
    );
  }

  /// `Upload File`
  String get uploadFile {
    return Intl.message(
      'Upload File',
      name: 'uploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Enter Message`
  String get enterMessage {
    return Intl.message(
      'Enter Message',
      name: 'enterMessage',
      desc: '',
      args: [],
    );
  }

  /// `No Chats`
  String get noChats {
    return Intl.message(
      'No Chats',
      name: 'noChats',
      desc: '',
      args: [],
    );
  }

  /// `No Groups`
  String get noGroups {
    return Intl.message(
      'No Groups',
      name: 'noGroups',
      desc: '',
      args: [],
    );
  }

  /// `No Users`
  String get noUsers {
    return Intl.message(
      'No Users',
      name: 'noUsers',
      desc: '',
      args: [],
    );
  }

  /// `No Messages`
  String get noMessages {
    return Intl.message(
      'No Messages',
      name: 'noMessages',
      desc: '',
      args: [],
    );
  }

  /// `No Globes`
  String get noGlobes {
    return Intl.message(
      'No Globes',
      name: 'noGlobes',
      desc: '',
      args: [],
    );
  }

  /// `Upload Media`
  String get uploadMedia {
    return Intl.message(
      'Upload Media',
      name: 'uploadMedia',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `You should have camera permission`
  String get youShouldHaveCameraPermission {
    return Intl.message(
      'You should have camera permission',
      name: 'youShouldHaveCameraPermission',
      desc: '',
      args: [],
    );
  }

  /// `You should have gallery permission`
  String get youShouldHaveGalleryPermission {
    return Intl.message(
      'You should have gallery permission',
      name: 'youShouldHaveGalleryPermission',
      desc: '',
      args: [],
    );
  }

  /// `Fill all the fields`
  String get fillAllFields {
    return Intl.message(
      'Fill all the fields',
      name: 'fillAllFields',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Send Friend Requests`
  String get sendFriendRequests {
    return Intl.message(
      'Send Friend Requests',
      name: 'sendFriendRequests',
      desc: '',
      args: [],
    );
  }

  /// `View Friends`
  String get viewFriends {
    return Intl.message(
      'View Friends',
      name: 'viewFriends',
      desc: '',
      args: [],
    );
  }

  /// `View Friend Requests`
  String get viewFriendRequests {
    return Intl.message(
      'View Friend Requests',
      name: 'viewFriendRequests',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get areYouSureYouWantToLogOut {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'areYouSureYouWantToLogOut',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOut {
    return Intl.message(
      'Log Out',
      name: 'logOut',
      desc: '',
      args: [],
    );
  }

  /// `No Found Users Until Now`
  String get noFoundUsersUntilNow {
    return Intl.message(
      'No Found Users Until Now',
      name: 'noFoundUsersUntilNow',
      desc: '',
      args: [],
    );
  }

  /// `No Found Chats Until Now`
  String get noFoundChatsUntilNow {
    return Intl.message(
      'No Found Chats Until Now',
      name: 'noFoundChatsUntilNow',
      desc: '',
      args: [],
    );
  }

  /// `No Found Groups Until Now`
  String get noFoundGroupsUntilNow {
    return Intl.message(
      'No Found Groups Until Now',
      name: 'noFoundGroupsUntilNow',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Request sent successfully`
  String get requestSent {
    return Intl.message(
      'Request sent successfully',
      name: 'requestSent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Friend Request`
  String get cancelFriendRequest {
    return Intl.message(
      'Cancel Friend Request',
      name: 'cancelFriendRequest',
      desc: '',
      args: [],
    );
  }

  /// `Accept Friend Request`
  String get acceptFriendRequest {
    return Intl.message(
      'Accept Friend Request',
      name: 'acceptFriendRequest',
      desc: '',
      args: [],
    );
  }

  /// `UnFriend`
  String get unFriend {
    return Intl.message(
      'UnFriend',
      name: 'unFriend',
      desc: '',
      args: [],
    );
  }

  /// `Friend Request Accepted`
  String get friendRequestAccepted {
    return Intl.message(
      'Friend Request Accepted',
      name: 'friendRequestAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Request Canceled`
  String get requestCanceled {
    return Intl.message(
      'Request Canceled',
      name: 'requestCanceled',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friends {
    return Intl.message(
      'Friends',
      name: 'friends',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get friendsRequests {
    return Intl.message(
      'Requests',
      name: 'friendsRequests',
      desc: '',
      args: [],
    );
  }

  /// `No Friends Yet`
  String get noFriendsYet {
    return Intl.message(
      'No Friends Yet',
      name: 'noFriendsYet',
      desc: '',
      args: [],
    );
  }

  /// `No Friend Requests Yet`
  String get noFriendRequestsYet {
    return Intl.message(
      'No Friend Requests Yet',
      name: 'noFriendRequestsYet',
      desc: '',
      args: [],
    );
  }

  /// `No Messages Yet`
  String get noMessagesYet {
    return Intl.message(
      'No Messages Yet',
      name: 'noMessagesYet',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  /// `About Me`
  String get aboutMe {
    return Intl.message(
      'About Me',
      name: 'aboutMe',
      desc: '',
      args: [],
    );
  }

  /// `Start Conversation`
  String get startConversation {
    return Intl.message(
      'Start Conversation',
      name: 'startConversation',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get you {
    return Intl.message(
      'You',
      name: 'you',
      desc: '',
      args: [],
    );
  }

  /// `Audio`
  String get audio {
    return Intl.message(
      'Audio',
      name: 'audio',
      desc: '',
      args: [],
    );
  }

  /// `You should have audio permission`
  String get youShouldHaveAudioPermission {
    return Intl.message(
      'You should have audio permission',
      name: 'youShouldHaveAudioPermission',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message(
      'File',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
      desc: '',
      args: [],
    );
  }

  /// `Public Group`
  String get publicGroup {
    return Intl.message(
      'Public Group',
      name: 'publicGroup',
      desc: '',
      args: [],
    );
  }

  /// `Private Group`
  String get privateGroup {
    return Intl.message(
      'Private Group',
      name: 'privateGroup',
      desc: '',
      args: [],
    );
  }

  /// `Create Group`
  String get createGroup {
    return Intl.message(
      'Create Group',
      name: 'createGroup',
      desc: '',
      args: [],
    );
  }

  /// `Group Settings`
  String get groupSettings {
    return Intl.message(
      'Group Settings',
      name: 'groupSettings',
      desc: '',
      args: [],
    );
  }

  /// `Edit Group Settings`
  String get editGroupSettings {
    return Intl.message(
      'Edit Group Settings',
      name: 'editGroupSettings',
      desc: '',
      args: [],
    );
  }

  /// `Only admins can edit group settings,as Info, image and description`
  String get onlyAdminsCanEditGroupSettings {
    return Intl.message(
      'Only admins can edit group settings,as Info, image and description',
      name: 'onlyAdminsCanEditGroupSettings',
      desc: '',
      args: [],
    );
  }

  /// `Approve New Members`
  String get approveNewMembers {
    return Intl.message(
      'Approve New Members',
      name: 'approveNewMembers',
      desc: '',
      args: [],
    );
  }

  /// `New members will be approved only after admin approval`
  String get NewMembersWillBeApprovedOnlyAfterAdminApproval {
    return Intl.message(
      'New members will be approved only after admin approval',
      name: 'NewMembersWillBeApprovedOnlyAfterAdminApproval',
      desc: '',
      args: [],
    );
  }

  /// `Request incoming members to join the group before viewing the group`
  String get requestIncomingMembersToJoinTheGroupBeforeViewingTheGroup {
    return Intl.message(
      'Request incoming members to join the group before viewing the group',
      name: 'requestIncomingMembersToJoinTheGroupBeforeViewingTheGroup',
      desc: '',
      args: [],
    );
  }

  /// `Request to Join Group`
  String get requestToJoinGroup {
    return Intl.message(
      'Request to Join Group',
      name: 'requestToJoinGroup',
      desc: '',
      args: [],
    );
  }

  /// `Lock Massages`
  String get lockMassages {
    return Intl.message(
      'Lock Massages',
      name: 'lockMassages',
      desc: '',
      args: [],
    );
  }

  /// `Only admins can send messages other members can not send messages`
  String get onlyAdminsCanSendMessagesOtherMembersCanNotSendMessages {
    return Intl.message(
      'Only admins can send messages other members can not send messages',
      name: 'onlyAdminsCanSendMessagesOtherMembersCanNotSendMessages',
      desc: '',
      args: [],
    );
  }

  /// `Select Group Admin`
  String get selectGroupAdmin {
    return Intl.message(
      'Select Group Admin',
      name: 'selectGroupAdmin',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Group Description`
  String get groupDescription {
    return Intl.message(
      'Group Description',
      name: 'groupDescription',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get private {
    return Intl.message(
      'Private',
      name: 'private',
      desc: '',
      args: [],
    );
  }

  /// `Public`
  String get public {
    return Intl.message(
      'Public',
      name: 'public',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `My Media`
  String get myMedia {
    return Intl.message(
      'My Media',
      name: 'myMedia',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Change Theme`
  String get changeTheme {
    return Intl.message(
      'Change Theme',
      name: 'changeTheme',
      desc: '',
      args: [],
    );
  }

  /// `Change Language`
  String get changeLanguage {
    return Intl.message(
      'Change Language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'areYouSureYouWantToLogout?' key
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
