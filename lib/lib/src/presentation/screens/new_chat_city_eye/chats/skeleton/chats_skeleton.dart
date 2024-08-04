import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class ChatsSkeleton extends StatelessWidget {
  const ChatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true,
              child: Column(
                children: [
                  _buildChatAppBarSkeleton(context),
                  Expanded(child: _buildSkeletonListView(context)),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SkeletonLine(
                      style: SkeletonLineStyle(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatAppBarSkeleton(BuildContext context) {
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SkeletonLine(
              style: SkeletonLineStyle(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      width: 100,
                      height: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: SkeletonLine(
                        style: SkeletonLineStyle(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      )),
                ],
              ),
            ),
            SkeletonLine(
              style: SkeletonLineStyle(
                width: 10,
                height: 5,
                borderRadius: BorderRadius.circular(5),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonListView(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          itemBuilder: (context, index) =>
              _buildMessageSkeleton(context, index % 2 == 0),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: 20,
        ),
      ),
    );
  }

  Widget _buildMessageSkeleton(BuildContext context, bool isMe) {
    return isMe
        ? _buildMyMassageSkeleton(context)
        : _buildReceiverMassageSkeleton(context);
  }

  Widget _buildMyMassageSkeleton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: SkeletonLine(
            style: SkeletonLineStyle(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 50,
              borderRadius: BorderRadius.circular(5),
              alignment: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiverMassageSkeleton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 5, top: 5),
              child: SkeletonLine(
                style: SkeletonLineStyle(
                  width: 30,
                  height: 30,
                  borderRadius: BorderRadius.circular(50),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: MediaQuery.of(context).size.width * 0.3,
              ),
              child: SkeletonLine(
                style: SkeletonLineStyle(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  borderRadius: BorderRadius.circular(5),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
