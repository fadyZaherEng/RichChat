// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/save_image_to_storage.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/di/data_layer_injector.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/get_user_use_case.dart';
import 'package:rich_chat_copilot/lib/src/domain/usecase/set_user_use_case.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<CancelFriendRequestEvent>(_onCancelFriendRequest);
    on<UnfriendEvent>(_onUnfriendEvent);
    on<ShowImageEvent>(_onShowImageEvent);
  }

  FutureOr<void> _onSendFriendRequest(
      SendFriendRequestEvent event, Emitter<ProfileState> emit) async {
    // emit(SendFriendRequestLoading());
    try {
      //TODO: implement send friend request
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.friendId)
          .update({
        "friendsRequestsUIds":
            FieldValue.arrayUnion([FirebaseSingleTon.auth.currentUser!.uid]),
      });
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(FirebaseSingleTon.auth.currentUser!.uid)
          .update({
        "sendFriendRequestsUIds": FieldValue.arrayUnion([event.friendId]),
      });
      emit(SendFriendRequestSuccess());
    } catch (e) {
      print(e);
      emit(SendFriendRequestFailed());
    }
  }

  FutureOr<void> _onAcceptFriendRequest(
      AcceptFriendRequestEvent event, Emitter<ProfileState> emit) async {
    emit(AcceptFriendRequestLoading());
    try {
      //TODO: implement accept friend request
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.friendId)
          .update({
        "friendsUIds":
            FieldValue.arrayUnion([FirebaseSingleTon.auth.currentUser!.uid]),
      });
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(FirebaseSingleTon.auth.currentUser!.uid)
          .update({
        "friendsUIds": FieldValue.arrayUnion([event.friendId]),
      });
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.friendId)
          .update({
        "sendFriendRequestsUIds":
            FieldValue.arrayRemove([FirebaseSingleTon.auth.currentUser!.uid]),
      });
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(FirebaseSingleTon.auth.currentUser!.uid)
          .update({
        "friendsRequestsUIds": FieldValue.arrayRemove([event.friendId]),
      });
      emit(AcceptFriendRequestSuccess());
    } catch (e) {
      print(e);
      emit(AcceptFriendRequestFailed());
    }
  }

  FutureOr<void> _onCancelFriendRequest(
      CancelFriendRequestEvent event, Emitter<ProfileState> emit) async {
    emit(CancelFriendRequestLoading());
    try {
      //TODO: implement cancel friend request
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.friendId)
          .update({
        "friendsRequestsUIds":
            FieldValue.arrayRemove([FirebaseSingleTon.auth.currentUser!.uid]),
      });
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(FirebaseSingleTon.auth.currentUser!.uid)
          .update({
        "sendFriendRequestsUIds": FieldValue.arrayRemove([event.friendId]),
      });
      emit(CancelFriendRequestSuccess());
    } catch (e) {
      print(e);
      emit(CancelFriendRequestFailed());
    }
  }

  FutureOr<void> _onUnfriendEvent(
      UnfriendEvent event, Emitter<ProfileState> emit) async {
    emit(UnFriendLoading());
    try {
      //TODO: implement unfriend
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.friendId)
          .update({
        "friendsUIds":
            FieldValue.arrayRemove([FirebaseSingleTon.auth.currentUser!.uid]),
      });
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(FirebaseSingleTon.auth.currentUser!.uid)
          .update({
        "friendsUIds": FieldValue.arrayRemove([event.friendId]),
      });
      emit(UnFriendSuccess());
    } catch (e) {
      print(e);
      emit(UnFriendFailed());
    }
  }

  FutureOr<void> _onShowImageEvent(
      ShowImageEvent event, Emitter<ProfileState> emit) async {
    emit(ShowImageState(imageUrl: event.file));
    String imageUrl = "";
    if (event.file != null) {
      imageUrl = await saveImageToStorage(event.file,
          "UserImages/${FirebaseSingleTon.auth.currentUser!.uid}.jpg");
      await _updateUserImage(
        FirebaseSingleTon.auth.currentUser!.uid,
        imageUrl,
      );
      emit(SaveGroupImageSuccessInSharedPreferencesState(imageUrl));
    }
  }

  // update user image
  Future<void> _updateUserImage(
    String id,
    String imageUrl,
  ) async {
    await FirebaseSingleTon.db
        .collection(Constants.users)
        .doc(id)
        .update({"image": imageUrl});
  }

// update name
  Future<String> updateName({
    required bool isGroup,
    required String id,
    required String newName,
    required String oldName,
  }) async {
    if (newName.isEmpty || newName.length < 3 || newName == oldName) {
      return 'Invalid name.';
    }

    if (isGroup) {
      await _updateGroupName(id, newName);
      final nameToReturn = newName;
      newName = '';
      emit(UpdateGroupNameSuccessState(nameToReturn));
      return nameToReturn;
    } else {
      await _updateUserName(id, newName);
      //get The Current User from Share Preferences
      UserModel userModel = GetUserUseCase(injector())();
      userModel.name = newName;
      // save user data to share preferences
      await SetUserUseCase(injector())(userModel);
      newName = '';
      emit(UpdateUserNameSuccessState(userModel.name));
      return userModel.name;
    }
  }

// update name
  Future<String> updateStatus({
    required bool isGroup,
    required String id,
    required String newDesc,
    required String oldDesc,
  }) async {
    if (newDesc.isEmpty || newDesc.length < 3 || newDesc == oldDesc) {
      return 'Invalid description.';
    }

    if (isGroup) {
      await _updateGroupDesc(id, newDesc);
      final descToReturn = newDesc;
      newDesc = '';
      emit(UpdateGroupDescriptionSuccessState(descToReturn));
      return descToReturn;
    } else {
      await _updateAboutMe(id, newDesc);
      //get The Current User from Share Preferences
      UserModel userModel = GetUserUseCase(injector())();
      userModel.aboutMe = newDesc;
      // save user data to share preferences
      await SetUserUseCase(injector())(userModel);
      newDesc = '';
      emit(UpdateAboutMeSuccessState(userModel.aboutMe));
      return userModel.aboutMe;
    }
  }

  // update groupName
  Future<void> _updateGroupName(String id, String newName) async {
    await FirebaseSingleTon.db.collection(Constants.groups).doc(id).update({
      "groupName": newName,
    });
  }

  // update userName
  Future<void> _updateUserName(String id, String newName) async {
    await FirebaseSingleTon.db
        .collection(Constants.users)
        .doc(id)
        .update({"name": newName});
  }

  // update aboutMe
  Future<void> _updateAboutMe(String id, String newDesc) async {
    await FirebaseSingleTon.db
        .collection(Constants.users)
        .doc(id)
        .update({"aboutMe": newDesc});
  }

  // update group desc
  Future<void> _updateGroupDesc(String id, String newDesc) async {
    await FirebaseSingleTon.db
        .collection(Constants.groups)
        .doc(id)
        .update({"groupDescription": newDesc});
  }
}
