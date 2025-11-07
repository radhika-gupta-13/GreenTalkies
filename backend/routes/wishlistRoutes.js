import express from "express";
import mongoose from "mongoose";
import Product from "../models/Product.js";

const router = express.Router();

// --------------------
// Wishlist Schema
// --------------------
const wishlistSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  product: { type: mongoose.Schema.Types.ObjectId, ref: "Product", required: true },
  createdAt: { type: Date, default: Date.now },
});

const Wishlist = mongoose.model("Wishlist", wishlistSchema);

// --------------------
// Add to wishlist
// --------------------
router.post("/add", async (req, res) => {
  try {
    const { userId, productId } = req.body;
    if (!userId || !productId) return res.status(400).json({ message: "UserId and ProductId required" });

    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ message: "Product not found" });

    const exists = await Wishlist.findOne({ user: userId, product: productId });
    if (exists) return res.status(400).json({ message: "Already in wishlist" });

    const item = new Wishlist({ user: userId, product: productId });
    await item.save();
    res.json({ message: "Added to wishlist", item });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// --------------------
// Get wishlist for a user
// --------------------
router.get("/list/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const items = await Wishlist.find({ user: userId }).populate("product");
    res.json(items);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// --------------------
// Remove from wishlist
// --------------------
router.delete("/remove/:userId/:itemId", async (req, res) => {
  try {
    const { userId, itemId } = req.params;
    const item = await Wishlist.findOneAndDelete({ _id: itemId, user: userId });
    if (!item) return res.status(404).json({ message: "Item not found" });
    res.json({ message: "Removed from wishlist" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
