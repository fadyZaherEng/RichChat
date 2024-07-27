part of 'group_bloc.dart';

@immutable
sealed class GroupState {}

final class GroupInitial extends GroupState {}

final class GroupLoadingState extends GroupState {}
final class GroupEditSettingsState extends GroupState {}
final class GroupApproveNewMembersState extends GroupState {}
final class GroupRequestToJoinState extends GroupState {}
final class GroupLockMassagesState extends GroupState {}
final class GroupModelState extends GroupState {}
final class GroupMembersListState extends GroupState {}
final class GroupAdminsListState extends GroupState {}
final class RemoveMemberFromGroupListState extends GroupState {}
final class RemoveMemberFromAdminListState extends GroupState {}
final class ClearGroupMembersListState extends GroupState {}
final class ClearGroupAdminsListState extends GroupState {}
final class CreateGroupSuccessState extends GroupState {}
final class CreateGroupErrorState extends GroupState {}
final class CreateGroupLoadingState extends GroupState {}
final class GroupMembersListUpdateSuccessState extends GroupState {}
final class GroupAdminsListUpdateSuccessState extends GroupState {}
final class ChangeGroupType extends GroupState{}
final class SendRequestToJoinGroupSuccessState extends GroupState{}
final class SendRequestToJoinGroupErrorState extends GroupState{}
final class AcceptRequestToJoinGroupSuccessState extends GroupState{}
final class AcceptRequestToJoinGroupErrorState extends GroupState{}
final class ExitGroupSuccessState extends GroupState{}
final class EditGroupNameSuccessState extends GroupState{}
final class EditGroupImageSuccessState extends GroupState{}
final class EditGroupDesSuccessState extends GroupState{}
final class ShowImagesState extends GroupState{
  final File image;

  ShowImagesState(this.image);
}
final class SaveGroupImageSuccessInSharedPreferencesState extends GroupState{
  final String image;
  SaveGroupImageSuccessInSharedPreferencesState(this.image);
}
final class EmptyTempListsState extends GroupState{}
final class UpdateGroupDataInFireStoreIfNeededState extends GroupState{}