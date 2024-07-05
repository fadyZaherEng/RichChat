// ignore_for_file: avoid_print

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<CancelFriendRequestEvent>(_onCancelFriendRequest);
    on<UnfriendEvent>(_onUnfriendEvent);
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
        "friendsRequestsUIds": FieldValue.arrayUnion([FirebaseSingleTon.auth.currentUser!.uid]),
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
      UnfriendEvent event, Emitter<ProfileState> emit) async{
    emit(UnFriendLoading());
    try {
      //TODO: implement unfriend
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.friendId)
          .update({
        "friendsUIds": FieldValue.arrayRemove([FirebaseSingleTon.auth.currentUser!.uid]),
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
}
