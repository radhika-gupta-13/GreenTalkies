import express from "express";
import cors from "cors";
import mongoose from "mongoose";
import dotenv from "dotenv";
import bodyParser from "body-parser";
import path from "path";

import Plant from "./models/Plant.js";
import Task from "./models/Task.js";
import GrovePost from "./models/GrovePost.js";
// --------------------
// Import Routes
// --------------------
import identifyRoute from "./routes/identify.js";
import diagnoseRoute from "./routes/diagnose.js";
import taskRoutes from "./routes/tasks.js";
import authRoutes from "./routes/auth.js"; // corrected
import plantRoutes from "./routes/plants.js";
import groveRoutes from "./routes/grove.js";
import userRoutes from "./routes/userRoute.js"; // new: create a separate user route for profile

// --------------------
// Config
// --------------------
dotenv.config({ path: "./details.env" });

const app = express();

// --------------------
// Middleware
// --------------------
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files
const __dirname = path.resolve();
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
app.use("/assets", express.static(path.join(path.resolve(), "assets")));

// --------------------
// MongoDB Connection
// --------------------
const uri = `mongodb+srv://${process.env.DB_USER}:${encodeURIComponent(
  process.env.DB_PASS
)}@cluster0.kqyyfl6.mongodb.net/${process.env.DB_NAME}?retryWrites=true&w=majority`;

mongoose
  .connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.log("❌ MongoDB Error:", err.message));

// --------------------
// Main Routes
// --------------------
app.use("/tasks", taskRoutes);
app.use("/auth", authRoutes);
app.use("/plants", plantRoutes);
app.use("/grove", groveRoutes);
app.use("/api/identify", identifyRoute);
app.use("/api/diagnose", diagnoseRoute);
app.use("/user", userRoutes);

// --------------------
// Bud & Basket Marketplace Routes
// --------------------
import Product from "./models/Product.js";
import Cart from "./models/Cart.js";
import Wishlist from "./models/Wishlist.js";
import Order from "./models/Order.js";

// Products
app.get("/products", async (req, res) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

app.get("/products/:id", async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: "Product not found" });
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Cart
app.post("/cart/add", async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    if (!userId || !productId || !quantity)
      return res.status(400).json({ message: "Missing required fields" });

    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ message: "Product not found" });

    const cartItem = new Cart({ user: userId, product: productId, quantity });
    await cartItem.save();

    res.status(200).json({ message: "Added to cart successfully", cartItem });
  } catch (err) {
    res.status(500).json({ message: "Failed to add to cart", error: err.message });
  }
});

// Wishlist
app.post("/wishlist/toggle", async (req, res) => {
  try {
    const { userId, productId } = req.body;
    if (!userId || !productId)
      return res.status(400).json({ message: "Missing required fields" });

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

// Orders
app.post("/order/create", async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    if (!userId || !productId || !quantity)
      return res.status(400).json({ message: "Missing required fields" });

    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ message: "Product not found" });

    const order = new Order({ user: userId, product: productId, quantity, status: "pending" });
    await order.save();

    res.status(200).json({ message: "Order placed successfully", order });
  } catch (err) {
    res.status(500).json({ message: "Failed to place order", error: err.message });
  }
});

// --------------------
// Server Startup
// --------------------
const PORT = process.env.PORT || 4000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
