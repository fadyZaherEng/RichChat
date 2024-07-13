import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/save_image_to_storage.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/group/group.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/user_info/user_info_bloc.dart';
import 'package:uuid/uuid.dart';

part 'group_event.dart';

part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc() : super(GroupInitial()) {
    on<SendRequestToJoinGroupEvent>(_onSendRequestToJoinGroupEvent);
    on<AcceptRequestToJoinGroupEvent>(_onAcceptRequestToJoinGroupEvent);
    on<ShowImageEvent>(_onShowImageEvent);
  }

  bool _isLoading = false;

  Group _group = Group(
    creatorUID: "",
    groupName: "",
    groupDescription: "",
    groupID: "",
    groupLogo: "",
    lastMessage: "",
    senderUID: "",
    timeSent: DateTime.now(),
    createAt: DateTime.now(),
    massageType: MassageType.text,
    massageID: "",
    isPrivate: true,
    editSettings: true,
    approveMembers: false,
    lockMassages: false,
    requestToJoin: false,
    membersUIDS: [],
    adminsUIDS: [],
    awaitingApprovalUIDS: [],
  );

  final List<UserModel> _groupMembersList = [];
  final List<UserModel> _groupAdminsList = [];

  //getter
  bool get iSLoading => _isLoading;

  // set group name
  void setGroupName(String groupName) {
    _group.groupName = groupName;
    emit(EditGroupNameSuccessState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

  // set group description
  void setGroupDescription(String groupDescription) {
    _group.groupDescription = groupDescription;
    emit(EditGroupDesSuccessState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

  // update image
  void setGroupImage(String groupImage) {
    _group.groupLogo = groupImage;
    emit(EditGroupImageSuccessState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

  Future<void> updateGroupDataInFirestore() async {
    try {
      await FirebaseSingleTon.db
          .collection(Constants.groups)
          .doc(_group.groupID)
          .update(_group.toMap());
    } catch (e) {
      print(e);
    }
  }

  Group get group => _group;

  List<UserModel> get groupMembersList => _groupMembersList;

  List<UserModel> get groupAdminsList => _groupAdminsList;

  //setter

  //loading
  void setLoading({required bool isLoading}) {
    _isLoading = isLoading;
    emit(GroupLoadingState());
  }

  //editSettings
  void setEditSettings({required bool editSettings}) {
    _group.editSettings = editSettings;
    emit(GroupEditSettingsState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

  //approveNewMembers
  void setApproveNewMembers({required bool approveNewMembers}) {
    _group.approveMembers = approveNewMembers;
    emit(GroupApproveNewMembersState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

  //requestToJoin
  void setRequestToJoin({required bool requestToJoin}) {
    _group.requestToJoin = requestToJoin;
    emit(GroupRequestToJoinState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

  //lockMassages
  void setLockMassages({required bool lockMassages}) {
    _group.lockMassages = lockMassages;
    emit(GroupLockMassagesState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

  //group
  Future<void> setGroup({required Group group}) async {
    _group = group;
    emit(GroupModelState());
  }

//groupMembersList
  void addMemberToGroup({required UserModel groupMember}) {
    _groupMembersList.add(groupMember);
    _group.membersUIDS.add(groupMember.uId);
    emit(GroupMembersListState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

//groupAdminsList
  void addMemberToAdmin({required UserModel groupAdmin}) {
    _groupAdminsList.add(groupAdmin);
    _group.adminsUIDS.add(groupAdmin.uId);
    emit(GroupAdminsListState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

//remove member from group
  void removeMemberFromGroup({required UserModel user}) {
    _groupMembersList.remove(user);
    _groupAdminsList.remove(user);
    _group.membersUIDS.remove(user.uId); //TODO: check this code
    emit(RemoveMemberFromGroupListState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

//remove member from admins
  void removeAdminFromAdmins({required UserModel user}) {
    _groupAdminsList.remove(user);
    _group.adminsUIDS.remove(user.uId);
    emit(RemoveMemberFromAdminListState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

// clear Group members
  Future clearGroupData() async {
    _groupMembersList.clear();
    _groupAdminsList.clear();
    _group = Group(
      creatorUID: "",
      groupName: "",
      groupDescription: "",
      groupID: "",
      groupLogo: "",
      lastMessage: "",
      senderUID: "",
      timeSent: DateTime.now(),
      createAt: DateTime.now(),
      massageType: MassageType.text,
      massageID: "",
      isPrivate: true,
      editSettings: true,
      approveMembers: false,
      lockMassages: false,
      requestToJoin: false,
      membersUIDS: [],
      adminsUIDS: [],
      awaitingApprovalUIDS: [],
    );
    emit(ClearGroupMembersListState());
  }

//get group members uids
  List<String> getGroupMembersUIDS() {
    return _groupMembersList.map((e) => e.uId).toList();
  }

//get group admins uids
  List<String> getGroupAdminsUIDS() {
    return _groupAdminsList.map((e) => e.uId).toList();
  }

//create group
  Future<void> createGroup({
    required Group newGroup,
    required File? image,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    setLoading(isLoading: true);
    emit(CreateGroupLoadingState());
    try {
      var groupId = const Uuid().v4();
      newGroup.groupID = groupId;
      //check if file image is null
      if (image != null) {
        final imageUrl =
            await saveImageToStorage(image, "groupsImages/$groupId");
        newGroup.groupLogo = imageUrl;
      }
      //add the group admins
      newGroup.adminsUIDS = [newGroup.creatorUID, ...getGroupAdminsUIDS()];
      //add the group members
      newGroup.membersUIDS = [newGroup.creatorUID, ...getGroupMembersUIDS()];
      setGroup(group: newGroup);
      //add edit settings
      //add group to firestore
      await FirebaseFirestore.instance
          .collection(Constants.groups)
          .doc(groupId)
          .set(newGroup.toMap());
      //on success
      onSuccess();
      setLoading(isLoading: false);
      emit(CreateGroupSuccessState());
    } catch (e) {
      setLoading(isLoading: false);
      onError(e.toString());
      emit(CreateGroupErrorState());
    }
  }

//get stream of all private groups that contains given userId
  Stream<List<Group>> getAllPrivateGroupsStream({
    required String userId,
  }) {
    return FirebaseFirestore.instance
        .collection(Constants.groups)
        .where("membersUIDS", arrayContains: userId)
        .where("isPrivate", isEqualTo: true)
        .snapshots()
        .asyncMap(
      (event) async {
        List<Group> groups = [];
        for (var element in event.docs) {
          groups.add(Group.fromMap(element.data()));
        }
        return groups;
      },
    );
  }

//get stream of all public groups that contains given userId
  Stream<List<Group>> getAllPublicGroupsStream({
    required String userId,
  }) {
    return FirebaseFirestore.instance
        .collection(Constants.groups)
        .where("membersUIDS", arrayContains: userId)
        .where("isPrivate", isEqualTo: false)
        .snapshots()
        .asyncMap(
      (event) async {
        List<Group> groups = [];
        for (var element in event.docs) {
          groups.add(Group.fromMap(element.data()));
        }
        return groups;
      },
    );
  }

//stream users data from firestore
  Stream<List<DocumentSnapshot>> streamGroupMembersData({
    required List<String> membersUIDS,
  }) {
    return Stream.fromFuture(
      Future.wait<DocumentSnapshot>(
        membersUIDS.map<Future<DocumentSnapshot>>(
          (uid) async {
            return await FirebaseFirestore.instance
                .collection(Constants.users)
                .doc(uid)
                .get();
          },
        ),
      ),
    );
  }

//get list of group members data from firestore with uids
  Future<List<UserModel>> getGroupMembersDataFromFirestore(
      {required bool isAdmin}) async {
    List<UserModel> groupMembersList = [];
    List<String> membersUIDS = isAdmin ? _group.adminsUIDS : _group.membersUIDS;
    for (var uid in membersUIDS) {
      var user = await FirebaseFirestore.instance
          .collection(Constants.users)
          .doc(uid)
          .get();
      groupMembersList.add(UserModel.fromJson(user.data()!));
    }
    return groupMembersList;
  }

//update group members list
  Future<void> updateGroupMembersList() async {
    _groupMembersList.clear();
    _groupMembersList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: false));
    emit(GroupMembersListUpdateSuccessState());
  }

//update group admins list
  Future<void> updateGroupAdminsList() async {
    _groupAdminsList.clear();
    _groupAdminsList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: true));
    emit(GroupAdminsListUpdateSuccessState());
  }

//changeGroupType
  void changeGroupType() {
    _group.isPrivate = !_group.isPrivate;
    emit(ChangeGroupType());
    updateGroupDataInFirestore();
  }

//send request to join group
  Future<void> sendRequestToJoinGroup({
    required String groupId,
    required String groupName,
    required String groupImage,
    required String uid,
  }) async {
    try {
      await FirebaseSingleTon.db
          .collection(Constants.groups)
          .doc(groupId)
          .update({
        "awaitingApprovalUIDS": FieldValue.arrayUnion([uid])
      });
      //send notification to group admin
      emit(SendRequestToJoinGroupSuccessState());
    } catch (e) {
      emit(SendRequestToJoinGroupErrorState());
    }
  }

//accept request to join group
  Future<void> acceptRequestToJoinGroup({
    required String groupId,
    required String uid,
  }) async {
    try {
      await FirebaseSingleTon.db
          .collection(Constants.groups)
          .doc(groupId)
          .update({
        "awaitingApprovalUIDS": FieldValue.arrayRemove([uid]),
        "membersUIDS": FieldValue.arrayUnion([uid])
      });
      _group.awaitingApprovalUIDS.remove(uid);
      _group.membersUIDS.add(uid);
      //send notification to group admin
      emit(AcceptRequestToJoinGroupSuccessState());
    } catch (e) {
      emit(AcceptRequestToJoinGroupErrorState());
    }
  }

  FutureOr<void> _onSendRequestToJoinGroupEvent(
      SendRequestToJoinGroupEvent event, Emitter<GroupState> emit) async {
    await sendRequestToJoinGroup(
      groupId: event.groupId,
      groupName: event.groupName,
      groupImage: event.groupImage,
      uid: event.uid,
    );
  }

  FutureOr<void> _onAcceptRequestToJoinGroupEvent(
      AcceptRequestToJoinGroupEvent event, Emitter<GroupState> emit) async {
    await acceptRequestToJoinGroup(
      groupId: event.groupId,
      uid: event.uid,
    );
  }

// check if is sender or admin
  bool isSenderOrAdmin({
    required Massage message,
    required String uid,
  }) {
    if (message.senderId == uid) {
      return true;
    } else if (_group.adminsUIDS.contains(uid)) {
      return true;
    } else {
      return false;
    }
  }

// exit group
  Future<void> exitGroup({
    required String uid,
  }) async {
    // check if the user is the admin of the group
    bool isAdmin = _group.adminsUIDS.contains(uid);
    await FirebaseSingleTon.db
        .collection(Constants.groups)
        .doc(_group.groupID)
        .update({
      "membersUIDS": FieldValue.arrayRemove([uid]),
      "adminsUIDS": isAdmin ? FieldValue.arrayRemove([uid]) : _group.adminsUIDS,
    });

    // remove the user from group members list
    _groupMembersList.removeWhere((element) => element.uId == uid);
    // remove the user from group members uid
    _group.membersUIDS.remove(uid);
    if (isAdmin) {
      // remove the user from group admins list
      _groupAdminsList.removeWhere((element) => element.uId == uid);
      // remove the user from group admins uid
      _group.adminsUIDS.remove(uid);
    }
    emit(ExitGroupSuccessState());
    if (_group.groupID.isEmpty) return;
    updateGroupDataInFirestore();
  }

  FutureOr<void> _onShowImageEvent(
      ShowImageEvent event, Emitter<GroupState> emit) async {
    String imageUrl = "";
    if (event.image != null) {
      imageUrl = await saveImageToStorage(
          event.image, "groupsImages/${event.groupId}");
      await _updateGroupImage(
        event.groupId,
        imageUrl,
      );
      emit(ShowImagesState(event.image));
      // emit(SaveGroupImageSuccessInSharedPreferencesState(imageUrl));
    }
  }

//update group image
  Future<void> _updateGroupImage(
    String id,
    String imageUrl,
  ) async {
    setGroupImage(imageUrl);
    await FirebaseSingleTon.db.collection(Constants.groups).doc(id).update(
      {"groupLogo": imageUrl},
    );
  }
}
