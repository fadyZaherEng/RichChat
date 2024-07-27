import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';

class MassageReply {
  final String massage;
  final String senderId;
  final String senderName;
  final String senderImage;
  final MassageType massageType;
  final bool isMe;
  const MassageReply({
    required this.massage,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.massageType,
    required this.isMe,
  });

  Map<String, dynamic> toJson() => {
        'massage': massage,
        'senderId': senderId,
        'senderName': senderName,
        'senderImage': senderImage,
        'massageType': massageType.name,
        'isMe': isMe,
      };

  factory MassageReply.fromJson(Map<String, dynamic> json) {
    return MassageReply(
      massage: json['massage'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderImage: json['senderImage'],
      massageType: json['massageType'].toString().massageTypeFromString,
      isMe: json['isMe'],
    );
  }
  MassageReply copyWith({
    String? massage,
    String? senderId,
    String? senderName,
    String? senderImage,
    MassageType? massageType,
    bool? isMe,
  }) {
    return MassageReply(
      massage: massage ?? this.massage,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      massageType: massageType ?? this.massageType,
      isMe: isMe ?? this.isMe,
    );
  }

}