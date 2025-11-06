import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/grove_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'post_detail_screen.dart';
import 'post_screen.dart';

// ----------------------------
// Hardcoded sample posts
// ----------------------------
List<GrovePostModel> samplePosts = [
  GrovePostModel(
    id: '1',
    username: 'Alice',
    userId: '101',
    content: 'Just planted my first Monstera! 🌱 Excited to see it grow.',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    topic: 'Plant Care',
    likes: ['102', '103'],
    comments: [
      Comment(id: 'c1', userId: '102', username: 'Bob', text: 'Congrats! 🥳'),
      Comment(id: 'c2', userId: '103', username: 'Carol', text: 'Monstera is the best!'),
    ],
    imageUrl: 'assets/monstera.jpg',
  ),
  GrovePostModel(
    id: '2',
    username: 'Bob',
    userId: '102',
    content: 'Does anyone know how often to water my Fiddle Leaf Fig?',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    topic: 'Watering',
    likes: [],
    comments: [],
    imageUrl: null,
  ),
  GrovePostModel(
    id: '3',
    username: 'Carol',
    userId: '103',
    content:
        'Here’s a tip: add a little coffee grounds to your soil for fertilization ☕🌿',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    topic: 'Fertilizing',
    likes: ['101'],
    comments: [
      Comment(id: 'c3', userId: '101', username: 'Alice', text: 'Nice tip! I will try this.'),
    ],
    imageUrl: null,
  ),
];

// ----------------------------
// Grove Screen
// ----------------------------
class GroveScreen extends StatefulWidget {
  final String userId;
  final String username;

  const GroveScreen({super.key, required this.userId, required this.username});

  @override
  State<GroveScreen> createState() => _GroveScreenState();
}

class _GroveScreenState extends State<GroveScreen> {
  List<GrovePostModel> posts = [];
  List<GrovePostModel> filteredPosts = [];
  bool isLoading = true;
  String? localIp;
  final uuid = const Uuid();
  String selectedTopic = 'All Topics';

  @override
  void initState() {
    super.initState();
    posts = List.from(samplePosts);
    initData();
  }

  Future<void> initData() async {
    await getLocalIp();
    await fetchPosts();
  }

  Future<void> getLocalIp() async {
    try {
      final info = NetworkInfo();
      final ip = await info.getWifiIP();
      setState(() => localIp = ip ?? '192.168.0.103'); // fallback
    } catch (e) {
      print("Error getting local IP: $e");
      setState(() => localIp = '192.168.0.103'); // fallback
    }
  }

  bool _isBackendPost(GrovePostModel post) => post.id.length == 24;

  Future<void> fetchPosts() async {
    if (localIp == null) return;
    setState(() => isLoading = true);
    final baseUrl = 'http://$localIp:4000';
    try {
      final response = await http.get(Uri.parse('$baseUrl/grove'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final backendPosts = data.map((e) => GrovePostModel.fromJson(e)).toList();
        final Map<String, GrovePostModel> merged = {};
        for (var sp in samplePosts) merged[sp.id] = sp;
        for (var bp in backendPosts) merged[bp.id] = bp;
        setState(() {
          posts = merged.values.toList()
            ..sort((a, b) {
              final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });
          applyTopicFilter();
          isLoading = false;
        });
      } else {
        setState(() {
          posts = List.from(samplePosts);
          applyTopicFilter();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching posts: $e");
      setState(() {
        posts = List.from(samplePosts);
        applyTopicFilter();
        isLoading = false;
      });
    }
  }

  void applyTopicFilter() {
    setState(() {
      if (selectedTopic == 'All Topics') {
        filteredPosts = List.from(posts);
      } else {
        filteredPosts = posts.where((p) => p.topic == selectedTopic).toList();
      }
    });
  }

  Future<void> likePost(GrovePostModel post) async {
    if (_isBackendPost(post)) {
      try {
        final response = await http.post(
          Uri.parse('http://$localIp:4000/grove/${post.id}/like'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': widget.userId}),
        );
        if (response.statusCode == 200) {
          setState(() {
            final index = posts.indexWhere((p) => p.id == post.id);
            if (index != -1) posts[index] = GrovePostModel.fromJson(jsonDecode(response.body));
            applyTopicFilter();
          });
        }
      } catch (e) {
        print("Error liking post: $e");
      }
    } else {
      setState(() {
        final index = posts.indexWhere((p) => p.id == post.id);
        if (index == -1) return;
        final p = posts[index];
        if (p.likes.contains(widget.userId)) {
          p.likes.remove(widget.userId);
        } else {
          p.likes.add(widget.userId);
        }
        applyTopicFilter();
      });
    }
  }

  Future<void> addComment(GrovePostModel post, String text) async {
    if (_isBackendPost(post)) {
      try {
        final response = await http.post(
          Uri.parse('http://$localIp:4000/grove/${post.id}/comment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': widget.userId,
            'username': widget.username,
            'text': text,
          }),
        );
        if (response.statusCode == 200) {
          setState(() {
            final index = posts.indexWhere((p) => p.id == post.id);
            if (index != -1) posts[index] = GrovePostModel.fromJson(jsonDecode(response.body));
            applyTopicFilter();
          });
        }
      } catch (e) {
        print("Error adding comment: $e");
      }
    } else {
      setState(() {
        final index = posts.indexWhere((p) => p.id == post.id);
        if (index == -1) return;
        posts[index].comments.add(
          Comment(id: uuid.v4(), userId: widget.userId, username: widget.username, text: text),
        );
        applyTopicFilter();
      });
    }
  }

  Future<void> deletePost(GrovePostModel post) async {
    if (_isBackendPost(post)) {
      try {
        final response = await http.delete(
          Uri.parse('http://$localIp:4000/grove/${post.id}'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userId": widget.userId}),
        );
        if (response.statusCode == 200) {
          setState(() => posts.removeWhere((p) => p.id == post.id));
          applyTopicFilter();
        }
      } catch (e) {
        print("Error deleting post: $e");
      }
    } else {
      setState(() {
        posts.removeWhere((p) => p.id == post.id);
        applyTopicFilter();
      });
    }
  }

  Future<void> deleteComment(GrovePostModel post, Comment comment) async {
    if (_isBackendPost(post)) {
      try {
        final response = await http.delete(
          Uri.parse('http://$localIp:4000/grove/${post.id}/comment/${comment.id}'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userId": widget.userId}),
        );
        if (response.statusCode == 200) {
          post.comments.removeWhere((c) => c.id == comment.id);
          applyTopicFilter();
        }
      } catch (e) {
        print("Error deleting comment: $e");
      }
    } else {
      setState(() {
        post.comments.removeWhere((c) => c.id == comment.id);
        applyTopicFilter();
      });
    }
  }

  void addNewPost(GrovePostModel newPost) {
    setState(() {
      posts.insert(0, newPost);
      applyTopicFilter();
    });
  }

  void selectTopic(String topic) {
    selectedTopic = topic;
    applyTopicFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Text(
          'The Grove Community',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: GTColors.lushGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchPosts,
              child: filteredPosts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No posts available on "$selectedTopic" 🌱\nBe the first to create one!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedTopic = 'All Topics';
                                applyTopicFilter();
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back to All Topics'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GTColors.lushGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      children: [
                        CommunityTopicsBar(selectedTopic: selectedTopic, onTopicSelected: selectTopic),
                        const SizedBox(height: 15),
                        ...filteredPosts.map(
                          (post) => GrovePostCard(
                            post: post,
                            currentUserId: widget.userId,
                            onLike: likePost,
                            onComment: addComment,
                            onDelete: deletePost,
                            onDeleteComment: deleteComment,
                            localIp: localIp,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(
                                    post: post,
                                    currentUserId: widget.userId,
                                    onLike: likePost,
                                    onComment: addComment,
                                    onDeletePost: deletePost,
                                    onDeleteComment: deleteComment,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newPost = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewPostScreen(
                currentUserId: widget.userId,
                currentUsername: widget.username,
              ),
            ),
          );
          if (newPost != null) addNewPost(newPost);
        },
        label: const Text('New Post', style: TextStyle(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add_comment_rounded),
        backgroundColor: GTColors.radiantGreen,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ---------------------------
// Topics Bar
// ---------------------------
class CommunityTopicsBar extends StatelessWidget {
  final String selectedTopic;
  final Function(String) onTopicSelected;

  const CommunityTopicsBar({super.key, required this.selectedTopic, required this.onTopicSelected});

  final List<String> topics = const [
    'All Topics',
    'Pest Control',
    'ID Help',
    'Watering',
    'Fertilizing',
    'Propagation',
    'Indoor Gardening',
    'Plant Care',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final isSelected = selectedTopic == topic;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ChoiceChip(
              label: Text(topic,
                  style: TextStyle(
                      color: isSelected ? Colors.white : GTColors.darkText,
                      fontWeight: FontWeight.bold)),
              selected: isSelected,
              onSelected: (_) => onTopicSelected(topic),
              selectedColor: GTColors.lushGreen,
              backgroundColor: GTColors.secondaryBaseLight,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------
// Post Card
// ---------------------------
class GrovePostCard extends StatefulWidget {
  final GrovePostModel post;
  final String currentUserId;
  final Function(GrovePostModel) onLike;
  final Function(GrovePostModel, String) onComment;
  final Function(GrovePostModel)? onDelete;
  final Function(GrovePostModel, Comment)? onDeleteComment;
  final VoidCallback? onTap;
  final String? localIp; // added

  const GrovePostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    this.onDelete,
    this.onDeleteComment,
    this.onTap,
    this.localIp,
  });

  @override
  State<GrovePostCard> createState() => _GrovePostCardState();
}

class _GrovePostCardState extends State<GrovePostCard> {
  bool showCommentField = false;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isLiked = post.likes.contains(widget.currentUserId);
    final formattedDate = post.createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(post.createdAt!)
        : '';

    String? displayImageUrl;
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      if (post.imageUrl!.startsWith('http')) {
        displayImageUrl = post.imageUrl!;
      } else if (post.imageUrl!.startsWith('/uploads')) {
        displayImageUrl = 'http://${widget.localIp}:4000${post.imageUrl}';
      } else {
        displayImageUrl = post.imageUrl!;
      }
    }

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: GTColors.primaryBaseDark.withOpacity(0.2),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: GTColors.primaryBaseDark)),
                              Text(formattedDate,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: GTColors.darkText.withOpacity(0.6))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: GTColors.radiantGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text('#${post.topic}',
                        style: const TextStyle(
                            color: GTColors.radiantGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                  if (widget.onDelete != null && post.userId == widget.currentUserId) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => widget.onDelete!(post),
                      child: const Icon(Icons.delete, color: Colors.red, size: 22),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(post.content, style: const TextStyle(fontSize: 16)),
              if (displayImageUrl != null && displayImageUrl.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: displayImageUrl.startsWith('http')
                      ? Image.network(
                          displayImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            );
                          },
                        )
                      : Image.asset(displayImageUrl, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () => widget.onLike(post),
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: isLiked ? GTColors.skyBlue : GTColors.darkText,
                    ),
                  ),
                  Text('${post.likes.length}'),
                  const SizedBox(width: 15),
                  IconButton(
                    onPressed: () {
                      setState(() => showCommentField = !showCommentField);
                    },
                    icon: const Icon(Icons.comment_outlined, color: GTColors.lushGreen),
                  ),
                  Text('${post.comments.length}'),
                ],
              ),
              if (showCommentField)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
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
                        icon: const Icon(Icons.send, color: GTColors.lushGreen),
                        onPressed: () {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty) {
                            widget.onComment(post, text);
                            commentController.clear();
                            setState(() => showCommentField = false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
