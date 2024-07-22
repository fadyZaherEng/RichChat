// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/core/utils/constants.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/group/group.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/group/group_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/screens/firends_requests/frients_requests_screen.dart';

navigationController({
  required BuildContext context,
  required RemoteMessage message,
}) {
  if (context == null) return;

  switch (message.data[Constants.notificationType]) {
    case Constants.chatNotification:
      //TODO: navigate to chat screen
      Navigator.pushNamed(
        context,
        Routes.chatWithFriendScreen,
        arguments: {
          "friendId": message.data["receiverId"],
          "friendName": message.data["receiverName"],
          "friendImage": message.data["receiverImage"],
          "groupId": ""
        },
      );
      break;
    case Constants.friendRequestNotification:
      // navigate to friend requests screen
      Navigator.pushNamed(
        context,
        Routes.friendRequestScreen,
      );
      break;
    case Constants.requestReplyNotification:
      // navigate to friend requests screen
      // navigate to friends screen
      Navigator.pushNamed(
        context,
        Routes.friendsScreen,
      );
      break;
    case Constants.groupRequestNotification:
      // navigate to friend requests screen
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return FriendRequestsScreen(
          groupId: message.data["groupId"],
        );
      }));
      break;

    case Constants.groupChatNotification:
      // parse the JSON string to a map
      Map<String, dynamic> jsonMap =
          jsonDecode(message.data["groupModel"]);
      // transform the map to a simple GroupModel object
      final Map<String, dynamic> flatGroupModelMap =
          flattenGroupModelMap(jsonMap);

      Group group = Group.fromMap(flatGroupModelMap);
      log('JSON: $jsonMap');
      log('Flat Map: $flatGroupModelMap');
      log('Group Model: $group');
      // navigate to group screen
      context
          .read<GroupBloc>()
          .setGroup(group: group)
          .whenComplete(() {
        //TODO: navigate to chat screen
        Navigator.pushNamed(
          context,
          Routes.chatWithFriendScreen,
          arguments: {
            "friendId":group.groupID ,
            "friendName": group.groupName,
            "friendImage": group.groupLogo,
            "groupId": group.groupID
          },
        );
      });
      break;
    // case Constants.friendRequestNotification:
    //   // navigate to friend requests screen
    //         Navigator.pushNamed(
    //           context,
    //           Constants.friendRequestsScreen,
    //         );
    // break;
    default:
      print('No Notification');
  }
}

// Function to transform the complex structure into a simple map
Map<String, dynamic> flattenGroupModelMap(Map<String, dynamic> complexMap) {
  Map<String, dynamic> flatMap = {};

  complexMap['_fieldsProto'].forEach((key, value) {
    switch (value['valueType']) {
      case 'stringValue':
        flatMap[key] = value['stringValue'];
        break;
      case 'booleanValue':
        flatMap[key] = value['booleanValue'];
        break;
      case 'integerValue':
        flatMap[key] = int.parse(value['integerValue']);
        break;
      case 'arrayValue':
        flatMap[key] = value['arrayValue']['values']
            .map<String>((item) => item['stringValue'] as String)
            .toList();
        break;
      // Add other cases if necessary
      default:
        // Handle unknown types
        flatMap[key] = null;
    }
  });

  return flatMap;
}
