import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../domain/entities/social_post.dart';
import '../stores/social_store.dart';

class SocialPostCard extends StatefulWidget {
  final SocialPost post;
  final SocialStore store;

  const SocialPostCard({super.key, required this.post, required this.store});

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Observer(
      builder: (_) {
        final post = widget.store.posts.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );

        return Card(
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.18),
                  child: Text(
                    post.avatarInitials,
                    style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.primary, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colorScheme.onSurface),
                      ),
                      Text(
                        post.userHandle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _PostTypeBadge(type: post.postType, colorScheme: colorScheme),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              post.description,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, height: 1.45),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: post.metrics.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.secondary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => widget.store.toggleLike(post.id),
                  icon: Icon(
                    post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: post.isLiked ? colorScheme.error : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                Text(
                  '${post.likesCount}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() => _showComments = !_showComments),
                  icon: Icon(Icons.mode_comment_outlined, size: 19, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  '${post.comments.length}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.share_outlined, size: 19, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            if (_showComments) ...[
              const SizedBox(height: 10),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 8),
              Column(
                children: post.comments.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${c.author}: ',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: colorScheme.secondary),
                        ),
                        Expanded(
                          child: Text(
                            c.text,
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add an authentic comment...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      widget.store.addComment(post.id, _commentController.text);
                      _commentController.clear();
                    },
                    icon: Icon(Icons.send_rounded, color: colorScheme.primary, size: 18),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
      },
    );
  }
}

class _PostTypeBadge extends StatelessWidget {
  final String type;
  final ColorScheme colorScheme;

  const _PostTypeBadge({required this.type, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    Color color = colorScheme.primary;
    String label = 'Milestone';

    if (type.contains('RUN')) {
      color = colorScheme.secondary;
      label = 'GPS Run';
    } else if (type.contains('RECOVERY')) {
      color = colorScheme.tertiary;
      label = 'Ring Recovery';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
