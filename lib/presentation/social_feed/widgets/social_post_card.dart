import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
    final post = widget.post;

    return Card(
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
                  backgroundColor: AppColors.emeraldPrimary.withOpacity(0.18),
                  child: Text(
                    post.avatarInitials,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.emeraldPrimary, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                      Text(post.userHandle, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                    ],
                  ),
                ),
                _PostTypeBadge(type: post.postType),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              post.description,
              style: const TextStyle(fontSize: 13, color: AppColors.darkTextSecondary, height: 1.45),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: post.metrics.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.cyanAccent),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.darkBorder),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => widget.store.toggleLike(post.id),
                  icon: Icon(
                    post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: post.isLiked ? AppColors.redAccent : AppColors.darkTextSecondary,
                    size: 20,
                  ),
                ),
                Text('${post.likesCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkTextSecondary)),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() => _showComments = !_showComments),
                  icon: const Icon(Icons.mode_comment_outlined, size: 19, color: AppColors.darkTextSecondary),
                ),
                Text('${post.comments.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkTextSecondary)),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, size: 19, color: AppColors.darkTextSecondary),
                ),
              ],
            ),
            if (_showComments) ...[
              const SizedBox(height: 10),
              const Divider(color: AppColors.darkBorder),
              const SizedBox(height: 8),
              Column(
                children: post.comments.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.author}: ', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.cyanAccent)),
                        Expanded(
                          child: Text(c.text, style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
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
                      decoration: const InputDecoration(
                        hintText: 'Add an authentic comment...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      widget.store.addComment(post.id, _commentController.text);
                      _commentController.clear();
                    },
                    icon: const Icon(Icons.send_rounded, color: AppColors.emeraldPrimary, size: 18),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostTypeBadge extends StatelessWidget {
  final String type;

  const _PostTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.emeraldPrimary;
    String label = 'Milestone';

    if (type.contains('RUN')) {
      color = AppColors.cyanAccent;
      label = 'GPS Run';
    } else if (type.contains('RECOVERY')) {
      color = AppColors.purpleAccent;
      label = 'Ring Recovery';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
