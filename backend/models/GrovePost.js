// models/GrovePost.js
import mongoose from "mongoose";

const CommentSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  username: { type: String, required: true },
  text: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

const GrovePostSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  username: { type: String, required: true },
  topic: { type: String, required: true },
  content: { type: String, required: true },
  imageUrl: { type: String },
  likes: [{ type: String }], // array of userIds who liked
  comments: [CommentSchema],
  createdAt: { type: Date, default: Date.now },
});

export default mongoose.models.GrovePost || mongoose.model("GrovePost", GrovePostSchema);
