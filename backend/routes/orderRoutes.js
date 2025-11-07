import express from "express";
import mongoose from "mongoose";
import Product from "../models/Product.js";

const router = express.Router();

// --------------------
// Order Schema
// --------------------
const orderSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  product: { type: mongoose.Schema.Types.ObjectId, ref: "Product", required: true },
  quantity: { type: Number, default: 1 },
  createdAt: { type: Date, default: Date.now },
});

const Order = mongoose.model("Order", orderSchema);

// --------------------
// Create order
// --------------------
router.post("/create", async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    if (!userId || !productId) return res.status(400).json({ message: "UserId and ProductId are required" });

    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ message: "Product not found" });

    const order = new Order({ user: userId, product: productId, quantity: quantity || 1 });
    await order.save();

    res.json({ message: "Order placed successfully", order });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
});

// --------------------
// Get all orders for a user
// --------------------
router.get("/list/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const orders = await Order.find({ user: userId }).populate("product");
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// --------------------
// Cancel / Delete an order
// --------------------
router.delete("/remove/:userId/:orderId", async (req, res) => {
  try {
    const { userId, orderId } = req.params;
    const order = await Order.findOneAndDelete({ _id: orderId, user: userId });
    if (!order) return res.status(404).json({ message: "Order not found" });
    res.json({ message: "Order canceled successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
