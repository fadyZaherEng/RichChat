import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';

class Group {
   String creatorUID;
   String groupName;
   String groupDescription;
   String groupID;
   String groupLogo;
   String lastMessage;
   String senderUID;
   DateTime timeSent;
   DateTime createAt;
   MassageType massageType;
   String massageID;
   bool isPrivate;
   bool editSettings;
   bool approveMembers;
   bool lockMassages;
   bool requestToJoin;
   List<String> membersUIDS;
   List<String> adminsUIDS;
   List<String> awaitingApprovalUIDS;

  Group({
    required this.creatorUID,
    required this.groupName,
    required this.groupDescription,
    required this.groupID,
    required this.groupLogo,
    required this.lastMessage,
    required this.senderUID,
    required this.timeSent,
    required this.createAt,
    required this.massageType,
    required this.massageID,
    required this.isPrivate,
    required this.editSettings,
    required this.approveMembers,
    required this.lockMassages,
    required this.requestToJoin,
    required this.membersUIDS,
    required this.adminsUIDS,
    required this.awaitingApprovalUIDS,
  });

// to map

  Map<String, dynamic> toMap() {
    return {
      'creatorUID': creatorUID,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupID': groupID,
      'groupLogo': groupLogo,
      'lastMessage': lastMessage,
      'senderUID': senderUID,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'createAt': createAt.millisecondsSinceEpoch,
      'massageType': massageType.name,
      'massageID': massageID,
      'isPrivate': isPrivate,
      'editSettings': editSettings,
      'approveMembers': approveMembers,
      'lockMassages': lockMassages,
      'requestToJoin': requestToJoin,
      'membersUIDS': membersUIDS,
      'adminsUIDS': adminsUIDS,
      'awaitingApprovalUIDS': awaitingApprovalUIDS
    };
  }

  //from map

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
        creatorUID: map['creatorUID'],
        groupName: map['groupName'],
        groupDescription: map['groupDescription'],
        groupID: map['groupID'],
        groupLogo: map['groupLogo'],
        lastMessage: map['lastMessage'],
        senderUID: map['senderUID'],
        timeSent: DateTime.fromMillisecondsSinceEpoch(
            map['timeSent'] ?? DateTime.now().millisecondsSinceEpoch),
        createAt: DateTime.fromMillisecondsSinceEpoch(
            map['createAt'] ?? DateTime.now().millisecondsSinceEpoch),
        massageType: map['massageType'].toString().massageTypeFromString,
        massageID: map['massageID'],
        isPrivate: map['isPrivate'],
        editSettings: map['editSettings'],
        approveMembers: map['approveMembers'],
        lockMassages: map['lockMassages'],
        requestToJoin: map['requestToJoin'],
        membersUIDS: List<String>.from(map['membersUIDS']),
        adminsUIDS: List<String>.from(map['adminsUIDS']),
        awaitingApprovalUIDS: List<String>.from(map['awaitingApprovalUIDS']));
  }

  //copy with

  Group copyWith({
    String? creatorUID,
    String? groupName,
    String? groupDescription,
    String? groupID,
    String? groupLogo,
    String? lastMessage,
    String? senderUID,
    DateTime? timeSent,
    DateTime? createAt,
    MassageType? massageType,
    String? massageID,
    bool? isPrivate,
    bool? editSettings,
    bool? approveMembers,
    bool? lockMassages,
    bool? requestToJoin,
    List<String>? membersUIDS,
    List<String>? adminsUIDS,
    List<String>? awaitingApprovalUIDS,
  }) {
    return Group(
      creatorUID: creatorUID ?? this.creatorUID,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      groupID: groupID ?? this.groupID,
      groupLogo: groupLogo ?? this.groupLogo,
      lastMessage: lastMessage ?? this.lastMessage,
      senderUID: senderUID ?? this.senderUID,
      timeSent: timeSent ?? this.timeSent,
      createAt: createAt ?? this.createAt,
      massageType: massageType ?? this.massageType,
      massageID: massageID ?? this.massageID,
      isPrivate: isPrivate ?? this.isPrivate,
      editSettings: editSettings ?? this.editSettings,
      approveMembers: approveMembers ?? this.approveMembers,
      lockMassages: lockMassages ?? this.lockMassages,
      requestToJoin: requestToJoin ?? this.requestToJoin,
      membersUIDS: membersUIDS ?? this.membersUIDS,
      adminsUIDS: adminsUIDS ?? this.adminsUIDS,
      awaitingApprovalUIDS: awaitingApprovalUIDS ?? this.awaitingApprovalUIDS,
    );
  }
}
