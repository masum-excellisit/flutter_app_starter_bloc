import 'package:flutter/material.dart';

import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags
                    .map((String tag) => Chip(
                          label: Text(tag),
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (post.reactions != null)
                  Row(
                    children: [
                      const Icon(Icons.thumb_up_off_alt, size: 16),
                      const SizedBox(width: 4),
                      Text('${post.reactions}'),
                    ],
                  ),
                const Spacer(),
                if (post.userId != null)
                  Text('User #${post.userId}',
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
