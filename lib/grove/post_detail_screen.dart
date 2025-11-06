import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:intl/intl.dart';
import 'package:greentalkies/models/grove_model.dart';

class PostDetailScreen extends StatefulWidget {
  final GrovePostModel post;
  final String currentUserId;
  final Function(GrovePostModel) onLike;
  final Function(GrovePostModel, String) onComment;
  final Function(GrovePostModel)? onDeletePost;
  final Function(GrovePostModel, Comment)? onDeleteComment;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    this.onDeletePost,
    this.onDeleteComment,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  bool showCommentField = false;
  final TextEditingController commentController = TextEditingController();
  late final AnimationController _likeAnimationController;
  late final Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _triggerLikeAnimation() {
    _likeAnimationController.forward(from: 0).then((_) {
      if (mounted) _likeAnimationController.reverse();
    });
  }

  Widget _buildPostImage(String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 180,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 180,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isLiked = post.likes.contains(widget.currentUserId);
    final formattedDate = post.createdAt != null
        ? DateFormat('MMM d, yyyy • h:mm a').format(post.createdAt!)
        : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        title: Text(post.username),
        actions: [
          if (widget.onDeletePost != null &&
              post.userId == widget.currentUserId)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                widget.onDeletePost!(post);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildPostImage(post.imageUrl),
            ],
            const SizedBox(height: 10),
            Text(
              '#${post.topic}',
              style: const TextStyle(
                color: GTColors.radiantGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formattedDate,
              style: TextStyle(
                color: GTColors.darkText.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const Divider(height: 30),
            Row(
              children: [
                ScaleTransition(
                  scale: _likeScaleAnimation,
                  child: IconButton(
                    onPressed: () {
                      widget.onLike(post);
                      _triggerLikeAnimation();
                      setState(() {});
                    },
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: isLiked ? GTColors.skyBlue : GTColors.darkText,
                    ),
                  ),
                ),
                Text('${post.likes.length}'),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    setState(() {
                      showCommentField = !showCommentField;
                    });
                  },
                  icon: const Icon(
                    Icons.comment_outlined,
                    color: GTColors.lushGreen,
                  ),
                ),
                Text('${post.comments.length}'),
              ],
            ),
            if (showCommentField)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final text = commentController.text.trim();
                      if (text.isNotEmpty) {
                        widget.onComment(post, text);
                        commentController.clear();
                        setState(() {
                          showCommentField = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.send, color: GTColors.lushGreen),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeIn,
              child: post.comments.isEmpty
                  ? const Center(
                      key: ValueKey('no_comments'),
                      child: Text(
                        'Be the first to comment 🌱',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      key: const ValueKey('comments_list'),
                      children: post.comments
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      GTColors.primaryBaseDark.withOpacity(0.2),
                                  child: const Icon(
                                    Icons.person,
                                    color: GTColors.primaryBaseDark,
                                  ),
                                ),
                                title: Text(
                                  c.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(c.text),
                                trailing: (c.userId == widget.currentUserId &&
                                        widget.onDeleteComment != null)
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            widget.onDeleteComment!(post, c),
                                      )
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
