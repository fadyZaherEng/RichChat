import 'package:equatable/equatable.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';

class LastMassage extends Equatable{
  final String massage;
  final String senderId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final MassageType massageType;
  final DateTime timeSent;
  final bool isSeen;

  const LastMassage({
    required this.massage,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.massageType,
    required this.timeSent,
    required this.isSeen,
  });

  Map<String, dynamic> toJson() => {
        'massage': massage,
        'senderId': senderId,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'receiverImage': receiverImage,
        'massageType': massageType.name,
        'timeSent': timeSent.microsecondsSinceEpoch,
        'isSeen': isSeen,
      };

  factory LastMassage.fromJson(Map<String, dynamic> json) => LastMassage(
        massage: json['massage'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        receiverName: json['receiverName'],
        receiverImage: json['receiverImage'],
        massageType: json['massageType'].toString().massageTypeFromString,
        timeSent: DateTime.fromMicrosecondsSinceEpoch(json['timeSent']),
        isSeen: json['isSeen'],
      );

  LastMassage deepClone() => LastMassage(
        massage: massage,
        senderId: senderId,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverImage: receiverImage,
        massageType: massageType,
        timeSent: timeSent,
        isSeen: isSeen,
      );

  LastMassage copyWith({
    String? massage,
    String? senderId,
    String? receiverId,
    String? receiverName,
    String? receiverImage,
    MassageType? massageType,
    DateTime? timeSent,
    bool? isSeen,
  }) =>
      LastMassage(
        massage: massage ?? this.massage,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        receiverName: receiverName ?? this.receiverName,
        receiverImage: receiverImage ?? this.receiverImage,
        massageType: massageType ?? this.massageType,
        timeSent: timeSent ?? this.timeSent,
        isSeen: isSeen ?? this.isSeen,
      );

  @override
  List<Object?> get props => [
    massage,
    senderId,
    receiverId,
    receiverName,
    receiverImage,
    massageType,
    timeSent,
    isSeen,
  ];
}
