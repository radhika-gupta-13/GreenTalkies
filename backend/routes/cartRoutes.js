import express from "express";
import mongoose from "mongoose";
import Product from "../models/Product.js";

const router = express.Router();

// --------------------
// Cart Schema
// --------------------
const cartSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  product: { type: mongoose.Schema.Types.ObjectId, ref: "Product", required: true },
  quantity: { type: Number, default: 1 },
});

const Cart = mongoose.model("Cart", cartSchema);

// --------------------
// Add product to cart
// --------------------
router.post("/add", async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    if (!userId || !productId) return res.status(400).json({ message: "UserId and ProductId are required" });

    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ message: "Product not found" });

    // Check if product already in user's cart
    let cartItem = await Cart.findOne({ user: userId, product: productId });
    if (cartItem) {
      cartItem.quantity += quantity || 1;
      await cartItem.save();
    } else {
      cartItem = new Cart({ user: userId, product: productId, quantity: quantity || 1 });
      await cartItem.save();
    }

    res.json({ message: "Added to cart", cartItem });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
});

// --------------------
// Get all cart items for a user
// --------------------
router.get("/list/:userId", async (req, res) => {
  try {
    const userId = req.params.userId;
    const items = await Cart.find({ user: userId }).populate("product");
    res.json(items);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// --------------------
// Remove item from cart
// --------------------
router.delete("/remove/:userId/:cartId", async (req, res) => {
  try {
    const { userId, cartId } = req.params;
    const cartItem = await Cart.findOneAndDelete({ _id: cartId, user: userId });
    if (!cartItem) return res.status(404).json({ message: "Item not found" });
    res.json({ message: "Removed from cart" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
