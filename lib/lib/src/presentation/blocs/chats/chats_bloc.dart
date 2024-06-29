// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rich_chat_copilot/generated/l10n.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/enum/massage_type.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/save_image_to_storage.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/last_massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/massage_reply.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/login/user.dart';
import 'package:uuid/uuid.dart';

part 'chats_event.dart';

part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc() : super(ChatsInitial()) {
    on<GetAllUsersEvent>(_onGetAllUsersEvent);
    on<GetCurrentUserEvent>(_onGetCurrentUserEvent);
    on<SendTextMessageEvent>(_onSendTextMessageEvent);
    on<SendFileMessageEvent>(_onSendFileMessageEvent);
    on<SelectImageEvent>(_onSelectImageEvent);
    on<SelectVideoFromGalleryEvent>(_onSelectVideoFromGalleryEvent);
    on<SelectReactionEvent>(_onSelectReactionEven);
  }

  //replay message
  MassageReply? _massageReply;

  MassageReply? get massageReply => _massageReply;

  void setMassageReply(MassageReply? massageReply) {
    _massageReply = massageReply;
    emit(SetMassageReplyState(massageReply: massageReply));
  }

  FutureOr<void> _onGetAllUsersEvent(
      GetAllUsersEvent event, Emitter<ChatsState> emit) async {
    emit(GetUserChatsLoading());
    try {
      List<UserModel> users = [];
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          users.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
        }
      });
      emit(GetUserChatsSuccess(users: users));
    } catch (e) {
      emit(GetUserChatsError(message: e.toString()));
    }
  }

  FutureOr<void> _onGetCurrentUserEvent(
      GetCurrentUserEvent event, Emitter<ChatsState> emit) async {
    emit(GetCurrentUserChatsLoading());
    try {
      UserModel user = UserModel();
      DocumentSnapshot doc = await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(event.uid)
          .get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      emit(GetCurrentUserChatsSuccess(user: user));
    } catch (e) {
      emit(GetCurrentUserChatsError(message: e.toString()));
    }
  }

  FutureOr<void> _onSendTextMessageEvent(
      SendTextMessageEvent event, Emitter<ChatsState> emit) async {
    emit(SendTextMessageLoading());
    //generate id to massage
    var massageId = const Uuid().v4();
    //check if massage is reply then add replied message to massage
    String repliedMessage = _massageReply?.massage ?? "";
    String repliedTo = _massageReply == null
        ? ""
        : _massageReply!.isMe
            ? S.of(event.context).you
            : _massageReply!.senderName;
    MassageType repliedMessageType =
        _massageReply?.massageType ?? MassageType.text;
    //update massage model with replied message
    final massage = Massage(
        senderId: event.sender.uId,
        senderName: event.sender.name,
        senderImage: event.sender.image,
        receiverId: event.receiverId,
        massage: event.message,
        massageType: event.massageType,
        timeSent: DateTime.now(),
        messageId: massageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: []);
    //check if group massage and send to group else send to contact
    if (event.groupId.isNotEmpty) {
      //handle group massage
    } else {
      //handle contact massage
      await _handleContactMassage(
        massage: massage,
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        receiverImage: event.receiverImage,
        success: () {
          emit(SendTextMessageSuccess());
        },
        failure: (String message) {
          emit(SendTextMessageError(message: message));
        },
      );
    }
    //emit success
    // emit(SendTextMessageSuccess());
    // try {} catch (e) {
    //   emit(SendTextMessageError(message: e.toString()));
    // }
  }

  Future<void> _handleContactMassage({
    required Massage massage,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required void Function() success,
    required void Function(String message) failure,
  }) async {
    try {
      final receiverMassage = massage.copyWith(receiverId: massage.senderId);
      //1-initialize last massage for sender
      final senderLastMassage = LastMassage(
        massage: massage.massage,
        senderId: massage.senderId,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverImage: receiverImage,
        massageType: massage.massageType,
        timeSent: massage.timeSent,
        isSeen: false,
      );
      //2-initialize last massage for receiver
      final receiverLastMassage = senderLastMassage.copyWith(
        receiverId: massage.senderId,
        receiverName: massage.senderName,
        receiverImage: massage.senderImage,
      );
      //3-send massage to receiver
      //4-send massage to sender
      //5-send last massage to receiver
      //6-send last massage to sender

      //1-send massage to receiver
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(receiverId)
          .collection(Constants.chats)
          .doc(massage.senderId)
          .collection(Constants.messages)
          .doc(massage.messageId)
          .set(receiverMassage.toJson());
      //2-send massage to sender
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(massage.senderId)
          .collection(Constants.chats)
          .doc(receiverId)
          .collection(Constants.messages)
          .doc(massage.messageId)
          .set(massage.toJson());
      success();
      //3-send last massage to receiver
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(receiverId)
          .collection(Constants.chats)
          .doc(massage.senderId)
          .set(receiverLastMassage.toJson());
      //4-send last massage to sender
      await FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(massage.senderId)
          .collection(Constants.chats)
          .doc(receiverId)
          .set(senderLastMassage.toJson());

      // await FirebaseSingleTon.db.runTransaction((transaction) async {
      //   //1-send massage to receiver
      //   transaction.set(
      //     FirebaseSingleTon.db
      //         .collection(Constants.users)
      //         .doc(receiverId)
      //         .collection(Constants.chats)
      //         .doc(massage.senderId)
      //         .collection(Constants.messages)
      //         .doc(massage.messageId),
      //     receiverMassage.toJson(),
      //   );
      //   //2-send massage to sender
      //   transaction.set(
      //     FirebaseSingleTon.db
      //         .collection(Constants.users)
      //         .doc(massage.senderId)
      //         .collection(Constants.chats)
      //         .doc(receiverId)
      //         .collection(Constants.messages)
      //         .doc(massage.messageId),
      //     massage.toJson(),
      //   );
      //   //3-send last massage to receiver
      //   transaction.set(
      //     FirebaseSingleTon.db
      //         .collection(Constants.users)
      //         .doc(receiverId)
      //         .collection(Constants.chats)
      //         .doc(massage.senderId),
      //     receiverLastMassage.toJson(),
      //   );
      //   //4-send last massage to sender
      //   transaction.set(
      //     FirebaseSingleTon.db
      //         .collection(Constants.users)
      //         .doc(massage.senderId)
      //         .collection(Constants.chats)
      //         .doc(receiverId),
      //     senderLastMassage.toJson(),
      //   );
      // }).then((value) {
      //   success();
      // }).catchError((error) {
      //   failure();
      // });
      //call success
      // success();
    } catch (e) {
      failure(e.toString());
    }
  }

  //get chats last massages stream
  Stream<List<LastMassage>> getChatsLastMassagesStream(
      {required String userId}) {
    return FirebaseSingleTon.db
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LastMassage.fromJson(doc.data()))
          .toList();
    });
  }

  //get massages stream
  Stream<List<Massage>> getMessagesStream({
    required String userId,
    required String receiverId,
    required String isGroup,
  }) {
    if (isGroup.isNotEmpty) {
      return FirebaseSingleTon.db
          .collection(Constants.groups)
          .doc(receiverId)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Massage.fromJson(doc.data()))
            .toList();
      });
    } else {
      //handle contact massage
      return FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(receiverId)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Massage.fromJson(doc.data()))
            .toList();
      });
    }
  }

  //set massage as seen
  Future<void> setMassageAsSeen({
    required String senderId,
    required String receiverId,
    required String massageId,
    required String groupId,
  }) async {
    try {
      //check if group
      if (groupId.isNotEmpty) {
        //handle group massage as seen
        await FirebaseSingleTon.db
            .collection(Constants.groups)
            .doc(groupId)
            .collection(Constants.messages)
            .doc(massageId)
            .update({Constants.isSeen: true});
      } else {
        //check if contact
        //set massage as seen for sender
        await FirebaseSingleTon.db
            .collection(Constants.users)
            .doc(senderId)
            .collection(Constants.chats)
            .doc(receiverId)
            .collection(Constants.messages)
            .doc(massageId)
            .update({Constants.isSeen: true});

        //set massage as seen for receiver
        await FirebaseSingleTon.db
            .collection(Constants.users)
            .doc(receiverId)
            .collection(Constants.chats)
            .doc(senderId)
            .collection(Constants.messages)
            .doc(massageId)
            .update({Constants.isSeen: true});
        //set last massage as seen for sender

        await FirebaseSingleTon.db
            .collection(Constants.users)
            .doc(senderId)
            .collection(Constants.chats)
            .doc(receiverId)
            .update({Constants.isSeen: true});
        //set last massage as seen for receiver
        await FirebaseSingleTon.db
            .collection(Constants.users)
            .doc(receiverId)
            .collection(Constants.chats)
            .doc(senderId)
            .update({Constants.isSeen: true});
        emit(SetMassageAsSeenSuccess());
      }
    } catch (e) {
      print(e.toString());
      emit(SetMassageAsSeenError(message: e.toString()));
    }
  }

  //sent file massage
  Future<void> sentFileMessage({
    required UserModel sender,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required String groupId,
    required File file,
    required BuildContext context,
    required MassageType massageType,
    required void Function() success,
    required void Function(String message) failure,
  }) async {
    //1-generate id to massage
    var massageId = const Uuid().v4();
    //2-check if massage is reply then add replied message to massage
    String repliedMessage = _massageReply?.massage ?? "";
    String repliedTo = _massageReply == null
        ? ""
        : _massageReply!.isMe
            ? S.of(context).you
            : _massageReply!.senderName;
    MassageType repliedMessageType =
        _massageReply?.massageType ?? MassageType.text;
    //3-upload file to storage
    String fileUrl = await saveImageToStorage(file,
        "chatFiles/${massageType.name}/${sender.uId}/$receiverId/$massageId.jpg");
    print("fileUrl: $fileUrl");
    //4-update massage model with replied message
    final massage = Massage(
      senderId: sender.uId,
      senderName: sender.name,
      senderImage: sender.image,
      receiverId: receiverId,
      massage: fileUrl,
      massageType: massageType,
      timeSent: DateTime.now(),
      messageId: massageId,
      isSeen: false,
      repliedMessage: repliedMessage,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
      reactions: [],
    );
    //check if group massage and send to group else send to contact
    if (groupId.isNotEmpty) {
      //handle group massage
    } else {
      //handle contact massage
      await _handleContactMassage(
        massage: massage,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverImage: receiverImage,
        success: () {
          success();
        },
        failure: (String error) {
          failure(error);
        },
      );
    }
  }

  FutureOr<void> _onSendFileMessageEvent(
      SendFileMessageEvent event, Emitter<ChatsState> emit) async {
    emit(SendFileMessageLoading());
    try {
      await sentFileMessage(
        sender: event.sender,
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        receiverImage: event.receiverImage,
        groupId: event.groupId,
        file: event.file,
        context: event.context,
        massageType: event.massageType,
        success: () {
          emit(SendFileMessageSuccess());
        },
        failure: (String error) {
          emit(SendFileMessageError(message: error));
        },
      );
    } catch (e) {
      emit(SendFileMessageError(message: e.toString()));
    }
  }

  FutureOr<void> _onSelectImageEvent(
      SelectImageEvent event, Emitter<ChatsState> emit) {
    emit(SelectImageState(file: event.file));
  }

  FutureOr<void> _onSelectVideoFromGalleryEvent(
      SelectVideoFromGalleryEvent event, Emitter<ChatsState> emit) {
    emit(SelectVideoFromGalleryState(file: event.file));
  }

  //send reactions to massage
  Future<void> _sendReactionsToMassage({
    required String massageId,
    required String senderId,
    required String receiverId,
    required String reaction,
    required bool groupId,
    required void Function() success,
    required void Function(String message) failure,
  }) async {
    try {
      //save reaction as $senderId=$reaction
      final String reactionToAdd = "$senderId=$reaction";
      //check if group massage and send to group else send to contact
      if (groupId) {
        //handle group massage
        //get reactions of massage list from firestore
        final massageData = await FirebaseSingleTon.db
            .collection(Constants.groups)
            .doc(receiverId)
            .collection(Constants.messages)
            .doc(massageId)
            .get();
        //add the massage data to massage
        final massage = Massage.fromJson(massageData.data()!);
        //check if reactions list empty
        if (massage.reactions.isEmpty) {
          //add reaction to massage
          await FirebaseSingleTon.db
              .collection(Constants.groups)
              .doc(receiverId)
              .collection(Constants.messages)
              .doc(massageId)
              .update({
            Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          //get UIDS list from reactions
          final List<String> UIDS =
              massage.reactions.map((e) => e.split("=")[0]).toList();
          //check if reaction already added
          if (UIDS.contains(senderId)) {
            //get index of reaction
            final int index = UIDS.indexOf(senderId);
            //replace reaction
            massage.reactions[index] = reactionToAdd;
          } else {
            //add reaction
            massage.reactions.add(reactionToAdd);
          }
          //update massage
          await FirebaseSingleTon.db
              .collection(Constants.groups)
              .doc(receiverId)
              .collection(Constants.messages)
              .doc(massageId)
              .update({Constants.reactions: massage.reactions});
        }
      } else {
        //handle contact massage
        print("$senderId $receiverId $massageId");
        //get reactions from firestore
        DocumentSnapshot<Map<String, dynamic>> massageData =
            await FirebaseSingleTon.db
                .collection(Constants.users)
                .doc(senderId)
                .collection(Constants.chats)
                .doc(receiverId)
                .collection(Constants.messages)
                .doc(massageId)
                .get();
        //add the massage data to massage
        final massage = Massage.fromJson(massageData.data()!);
        //check if reactions list empty
        if (massage.reactions.isEmpty) {
          //add reaction to massage
          await FirebaseSingleTon.db
              .collection(Constants.users)
              .doc(senderId)
              .collection(Constants.chats)
              .doc(receiverId)
              .collection(Constants.messages)
              .doc(massageId)
              .update({
            Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          //get UIDS list from reactions
          final List<String> UIDS =
              massage.reactions.map((e) => e.split("=")[0]).toList();
          //check if reaction already added
          if (UIDS.contains(senderId)) {
            //get index of reaction
            final int index = UIDS.indexOf(senderId);
            //replace reaction
            massage.reactions[index] = reactionToAdd;
          } else {
            //add reaction
            massage.reactions.add(reactionToAdd);
          }
          //update massage to sender
          await FirebaseSingleTon.db
              .collection(Constants.users)
              .doc(senderId)
              .collection(Constants.chats)
              .doc(receiverId)
              .collection(Constants.messages)
              .doc(massageId)
              .update({Constants.reactions: massage.reactions});
          //update massage to receiver
          await FirebaseSingleTon.db
              .collection(Constants.users)
              .doc(receiverId)
              .collection(Constants.chats)
              .doc(senderId)
              .collection(Constants.messages)
              .doc(massageId)
              .update({Constants.reactions: massage.reactions});
        }
      }
      print("sent");
      success();
    } catch (e) {
      print("ddddddddddddddddddddddddddddddddd${e.toString()}");
      failure(e.toString());
    }
  }

  FutureOr<void> _onSelectReactionEven(
      SelectReactionEvent event, Emitter<ChatsState> emit) async {
    emit(SendReactionsToMassageLoading());
    await _sendReactionsToMassage(
      massageId: event.massageId,
      senderId: event.senderId,
      receiverId: event.receiverId,
      reaction: event.reaction,
      groupId: event.groupId,
      success: () {
        emit(SendReactionsToMassageSuccess());
      },
      failure: (String message) {
        emit(SendReactionsToMassageError(message: message));
      },
    );
  }

  //get unread massages stream
  Stream<int> getUnreadMassagesStream({
    required String userId,
    required String receiverId,
    required bool isGroup,
  }) {
    if (isGroup) {
      return FirebaseSingleTon.db
          .collection(Constants.groups)
          .doc(receiverId)
          .collection(Constants.messages)
          .snapshots()
          .asyncMap((event) {
        int count = 0;
        for (var element in event.docs) {
          final massage = Massage.fromJson(element.data());
          if (!massage.isSeenBy.contains(userId)) {
            count++;
          }
        }
        return count;
      });
    } else {
      //handle contact massage
      return FirebaseSingleTon.db
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(receiverId)
          .collection(Constants.messages)
          .where(Constants.isSeen, isEqualTo: false)
          .where("senderId", isEqualTo: userId)
          .snapshots()
          .map((event) {
        return event.docs.length;
      });
    }
  }
}
