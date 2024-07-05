import 'package:flutter/material.dart';
import 'package:snapseek/components/extension.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

class ListActivityItem extends StatelessWidget {
  const ListActivityItem({super.key, required this.activity, required this.feedGroup});
  final EnrichedActivity activity;
  final String feedGroup;
  @override
  Widget build(BuildContext context) {
    final actor = activity.actor!;
    final attachments = (activity.extraData)?.toAttachments();
    final reactionCounts = activity.reactionCounts;
    final ownReactions = activity.ownReactions;
    final isLikedByUser = (ownReactions?['like']?.length ?? 0) > 0;

    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const SizedBox(width: 15),
            CircleAvatar(
              backgroundImage: actor.profileImage.isNotEmpty ? NetworkImage(actor.profileImage) : const AssetImage('lib/images/default_avatar.jpeg'),
            ),
            const SizedBox(width: 10),
            Text(actor.handle),
          ]
        )
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (attachments != null && attachments.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(attachments[0].url, scale: 0.85),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Text('${activity.object}', style: TextStyle(fontSize: 15, color: Colors.black)),
          ),
          Row(
            children: [
              IconButton(
                iconSize:16,
                onPressed: () {
                  if (isLikedByUser) {
                    context.feedBloc.onRemoveReaction(
                      kind: 'like',
                      activity: activity,
                      reaction: ownReactions!['like']![0],
                      feedGroup: feedGroup,
                    );
                  } else {
                    context.feedBloc.onAddReaction(
                      kind: 'like',
                      activity: activity,
                      feedGroup: feedGroup
                    );
                  }
                },
                icon: isLikedByUser
                  ? const Icon(Icons.favorite_rounded)
                  : const Icon(Icons.favorite_outline),
              ),
              if (reactionCounts?['like'] != null)
                Text(
                  '${reactionCounts?['like']}',
                )
            ],
          ),
        ]
      )
    );
  }
}