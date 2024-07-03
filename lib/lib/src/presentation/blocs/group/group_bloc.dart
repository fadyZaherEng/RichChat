import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/save_image_to_storage.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/group/group.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:uuid/uuid.dart';

part 'group_event.dart';

part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc() : super(GroupInitial()) {
    on<SendRequestToJoinGroupEvent>(_onSendRequestToJoinGroupEvent);
    on<AcceptRequestToJoinGroupEvent>(_onAcceptRequestToJoinGroupEvent);
  }

  bool _isLoading = false;

  // bool _editSettings = false;
  // bool _approveNewMembers = false;
  // bool _requestToJoin = false;
  // bool _lockMassages = false;
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

  // bool get editSettings => _editSettings;
  //
  // bool get approveNewMembers => _approveNewMembers;
  //
  // bool get requestToJoin => _requestToJoin;
  //
  // bool get lockMassages => _lockMassages;
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
      // group.editSettings = editSettings;
      // //add approve new members
      // group.approveMembers = approveNewMembers;
      // //add request to join
      // group.requestToJoin = requestToJoin;
      // //add lock massages
      // group.lockMassages = lockMassages;
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

  //stream group data
  Stream<DocumentSnapshot> getGroupStream({required String groupId}) {
    return FirebaseFirestore.instance
        .collection(Constants.groups)
        .doc(groupId)
        .snapshots();
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
    // return FirebaseFirestore.instance
    //     .collection(Constants.users)
    //     .where("uId", whereIn: membersUIDS)
    //     .snapshots()
    //     .asyncMap(
    //   (event) async {
    //     List<UserModel> users = [];
    //     for (var element in event.docs) {
    //       users.add(UserModel.fromJson(element.data()));
    //     }
    //     return users;
    //   },
    // );
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
        "awaitingApprovalUIDS": FieldValue.arrayRemove([uid])
      });
      await FirebaseSingleTon.db
          .collection(Constants.groups)
          .doc(groupId)
          .update({
        "membersUIDS": FieldValue.arrayUnion([uid])
      });
      //update group members list
      await updateGroupMembersList();
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
}
