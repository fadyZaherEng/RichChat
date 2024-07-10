import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_chat_copilot/lib/src/presentation/blocs/chats/chats_bloc.dart';

class UnReadMassageCounterWidget extends StatelessWidget {
  final String uid;
  final String receiverId;
  final bool isGroup;

  const UnReadMassageCounterWidget({
    super.key,
    required this.uid,
    required this.receiverId,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: context.read<ChatsBloc>().getUnreadMassagesStream(
          userId: uid, receiverId: receiverId, isGroup: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else {
          final unreadMassages = snapshot.data ?? 0;
          return unreadMassages > 0
              ? Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 1,
                          blurRadius: 6.0,
                          offset: Offset(0, 1),
                        ),
                      ]),
                  child: Text(
                    unreadMassages.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox();
        }
      },
    );
  }
}
