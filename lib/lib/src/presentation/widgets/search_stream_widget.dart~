import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/config/routes/routes_manager.dart';
import 'package:rich_chat_copilot/lib/src/domain/entities/chat/last_massage.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/chats/chats_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/widgets/last_massage_chat_widget.dart';

class SearchStreamWidget extends StatefulWidget {
  const SearchStreamWidget({
    super.key,
    required this.uid,//current user
    this.groupId = '',
  });

  final String uid;
  final String groupId;

  @override
  State<SearchStreamWidget> createState() => _SearchStreamWidgetState();
}

class _SearchStreamWidgetState extends State<SearchStreamWidget> {
  ChatsBloc get _bloc => BlocProvider.of<ChatsBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsBloc, ChatsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return StreamBuilder<QuerySnapshot>(
          stream: _bloc.getLastMessageStream(
            userId: widget.uid,
            groupId: widget.groupId,
          ),
          builder: (builderContext, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final results = snapshot.data!.docs.where(
              (element) => element["receiverName"]
                  .toString()
                  .toLowerCase()
                  .contains(_bloc.searchQuery.toLowerCase()),
            );

            if (results.isEmpty) {
              return const Center(
                child: Text('No chats found'),
              );
            }

            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final chat = LastMassage.fromJson(
                      results.elementAt(index).data() as Map<String, dynamic>);
                  return LastMassageChatWidget(
                    chats: chat,
                    isGroup: false,
                    onTap: () {
                      //TODO: navigate to chat screen
                      Navigator.pushNamed(
                        context,
                        Routes.chatWithFriendScreen,
                        arguments: {
                          "friendId": chat.receiverId,
                          "friendName": chat.receiverName,
                          "friendImage": chat.receiverImage,
                          "groupId":
                              widget.groupId.isEmpty ? '' : widget.groupId,
                        },
                      );
                    },
                  );
                },
              );
            }
            return const Center(
              child: Text('No chats found'),
            );
          },
        );
      },
    );
  }
}
