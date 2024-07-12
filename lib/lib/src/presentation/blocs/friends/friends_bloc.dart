import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';

part 'friends_event.dart';

part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  FriendsBloc() : super(FriendsInitial()) {
    on<GetFriends>(_onGetFriends);

    on<GetFriendsRequestsEvent>(_onGetFriendsRequestsEvent);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequestEvent);
  }

  FutureOr<void> _onGetFriendsRequestsEvent(
      GetFriendsRequestsEvent event, Emitter<FriendsState> emit) async {
    emit(GetFriendsRequestsLoading());
    try {
      List<UserModel> friendsRequests = [];
      if (event.groupId.isNotEmpty) {
        //get all friends of current user from firebase
        DocumentSnapshot documentSnapshot = await FirebaseSingleTon.db
            .collection(Constants.groups)
            .doc(event.groupId)
            .get();
        List<dynamic> requestsUIds = documentSnapshot.get("awaitingApprovalUIDS");
        for (String friendRequestUId in requestsUIds) {
          DocumentSnapshot documentSnapshot = await FirebaseSingleTon.db
              .collection(Constants.users)
              .doc(friendRequestUId)
              .get();
          UserModel friend =
          UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
          friendsRequests.add(friend);
        }
        emit(GetFriendsRequestsSuccess(friendsRequests: friendsRequests));
      }else{
        //get all friends of current user from firebase
        DocumentSnapshot documentSnapshot = await FirebaseSingleTon.db
            .collection(Constants.users)
            .doc(event.uid)
            .get();
        List<dynamic> friendUIds = documentSnapshot.get("friendsRequestsUIds");
        for (String friendRequestUId in friendUIds) {
          DocumentSnapshot documentSnapshot = await FirebaseSingleTon.db
              .collection(Constants.users)
              .doc(friendRequestUId)
              .get();
          UserModel friend =
          UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
          friendsRequests.add(friend);
        }
        emit(GetFriendsRequestsSuccess(friendsRequests: friendsRequests));
      }
    } catch (e) {
      emit(GetFriendsRequestsError(message: e.toString()));
    }
  }

  FutureOr<void> _onAcceptFriendRequestEvent(
      AcceptFriendRequestEvent event, Emitter<FriendsState> emit) async {
    emit(AcceptFriendRequestsLoading());
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
      emit(AcceptFriendRequestsSuccess());
    } catch (e) {
      print(e);
      emit(AcceptFriendRequestsError(message: e.toString()));
    }
  }

  FutureOr<void> _onGetFriends(
      GetFriends event, Emitter<FriendsState> emit) async {
    emit(GetFriendsLoading());
    try {
      List<UserModel> friends = [];
      //get all friends of current user from firebase
      DocumentSnapshot documentSnapshot = await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.uid)
          .get();
      List<dynamic> friendUIds = documentSnapshot.get("friendsUIds");

      for (String friendUId in friendUIds) {
        // if groupMembersUIDs list is not empty and contains the friendUID we skip this friend
        if (event.groupMembersUIDs.isNotEmpty && event.groupMembersUIDs.contains(friendUId)) {
          continue;
        }
        DocumentSnapshot documentSnapshot = await FirebaseSingleTon.db
            .collection(Constants.users)
            .doc(friendUId)
            .get();
        UserModel friend =
            UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
        friends.add(friend);
      }
      emit(GetFriendsSuccess(friends: friends));
    } catch (e) {
      emit(GetFriendsError(error: e.toString()));
    }
  }
}
