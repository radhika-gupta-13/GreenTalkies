import express from "express";
import GrovePost from "../models/GrovePost.js";
import multer from "multer";
import path from "path";
import fs from "fs";

const router = express.Router();

// Ensure uploads folder exists
const uploadDir = path.join('.', 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);

// Multer configuration
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage });

// Fetch all posts
router.get("/", async (req, res) => {
  try {
    const posts = await GrovePost.find().sort({ createdAt: -1 });
    res.json(posts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create new post with optional image
router.post("/", upload.single("image"), async (req, res) => {
  try {
    const { userId, username, topic, content } = req.body;
    if (!userId || !username || !topic || !content) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const imageUrl = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : "";

    const newPost = new GrovePost({ userId, username, topic, content, imageUrl });
    await newPost.save();

    res.status(201).json(newPost);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Like / Unlike post
router.post("/:postId/like", async (req, res) => {
  try {
    const { userId } = req.body;
    const post = await GrovePost.findById(req.params.postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    if (post.likes.includes(userId)) {
      post.likes = post.likes.filter(id => id !== userId);
    } else {
      post.likes.push(userId);
    }
    await post.save();
    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add comment
router.post("/:postId/comment", async (req, res) => {
  try {
    const { userId, username, text } = req.body;
    const post = await GrovePost.findById(req.params.postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    post.comments.push({ userId, username, text });
    await post.save();
    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Delete a post
router.delete("/:postId", async (req, res) => {
  try {
    const { userId } = req.body;
    const post = await GrovePost.findById(req.params.postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    if (post.userId !== userId) {
      return res.status(403).json({ message: "Not authorized to delete this post" });
    }

    await post.deleteOne();
    res.json({ message: "Post deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Delete a comment
router.delete("/:postId/comment/:commentId", async (req, res) => {
  try {
    const { userId } = req.body;
    const { postId, commentId } = req.params;

    const post = await GrovePost.findById(postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    const commentIndex = post.comments.findIndex(
      (c) => c._id.toString() === commentId && c.userId === userId
    );

    if (commentIndex === -1)
      return res.status(404).json({ message: "Comment not found or unauthorized" });

    post.comments.splice(commentIndex, 1);
    await post.save();

    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
