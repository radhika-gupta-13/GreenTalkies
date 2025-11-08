import express from "express";
import Product from "../models/Product.js";
import Cart from "../models/Cart.js";
import Wishlist from "../models/Wishlist.js";
import Order from "../models/Order.js";

const router = express.Router();

// -------------------------
// 🪴 PRODUCTS
// -------------------------
router.get("/products", async (req, res) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/products/:id", async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: "Not found" });
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// -------------------------
// 🛒 CART
// -------------------------
router.get("/cart/:userId", async (req, res) => {
  try {
    const cartItems = await Cart.find({ user: req.params.userId }).populate("product");
    res.json(cartItems);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/cart/add", async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    if (!userId || !productId || !quantity) return res.status(400).json({ message: "Missing required fields" });

    let cartItem = await Cart.findOne({ user: userId, product: productId });
    if (cartItem) {
      cartItem.quantity += quantity;
    } else {
      cartItem = new Cart({ user: userId, product: productId, quantity });
    }
    await cartItem.save();

    res.status(200).json({ message: "Added to cart successfully", cartItem });
  } catch (err) {
    res.status(500).json({ message: "Failed to add to cart", error: err.message });
  }
});

// -------------------------
// ❤️ WISHLIST
// -------------------------
router.get("/wishlist/:userId", async (req, res) => {
  try {
    const wishlistItems = await Wishlist.find({ user: req.params.userId }).populate("product");
    res.json(wishlistItems);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/wishlist/toggle", async (req, res) => {
  try {
    const { userId, productId } = req.body;
    if (!userId || !productId) return res.status(400).json({ message: "Missing required fields" });

    const existing = await Wishlist.findOne({ user: userId, product: productId });
    if (existing) {
      await existing.remove();
      return res.status(200).json({ message: "Removed from wishlist" });
    } else {
      const wishlistItem = new Wishlist({ user: userId, product: productId });
      await wishlistItem.save();
      return res.status(200).json({ message: "Added to wishlist" });
    }
  } catch (err) {
    res.status(500).json({ message: "Failed to toggle wishlist", error: err.message });
  }
});

// -------------------------
// 🛍️ ORDERS
// -------------------------
router.post("/order/create", async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    if (!userId || !productId || !quantity) return res.status(400).json({ message: "Missing required fields" });

    const order = new Order({ user: userId, product: productId, quantity, status: "pending" });
    await order.save();

    res.status(200).json({ message: "Order placed successfully", order });
  } catch (err) {
    res.status(500).json({ message: "Failed to place order", error: err.message });
  }
});

export default router;
