import express from "express";
import cors from "cors";
import mongoose from "mongoose";
import dotenv from "dotenv";
import bodyParser from "body-parser";
import os from "os";
import path from "path";

// --------------------
// Import Routes
// --------------------
import identifyRoute from "./routes/identify.js";
import diagnoseRoute from "./routes/diagnose.js";
import taskRoutes from "./routes/tasks.js";
import authRoutes from "./routes/auth.js";
import plantRoutes from "./routes/plants.js";
import groveRoutes from "./routes/grove.js";

// --------------------
// Import Models
// --------------------
import User from "./models/User.js";
import LoginHistory from "./models/LoginHistory.js";
import Plant from "./models/Plant.js";
import Task from "./models/Task.js";
import GrovePost from "./models/GrovePost.js";
import Product from "./models/Product.js";
import Cart from "./models/Cart.js";
import Wishlist from "./models/Wishlist.js";
import Order from "./models/Order.js";

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

// Serve static files
app.use("/uploads", express.static(path.join(".", "uploads")));
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

// --------------------
// User Routes
// --------------------
app.get("/user/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

app.put("/user/:id", async (req, res) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedUser) return res.status(404).json({ message: "User not found" });
    res.json(updatedUser);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// --------------------
// Signup / Login / Auth
// --------------------
app.post("/auth/signup", async (req, res) => {
  try {
    const { displayName, email, password } = req.body;
    if (!displayName || !email || !password)
      return res.status(400).json({ message: "All fields are required." });

    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(409).json({ message: "Email already exists." });

    const newUser = new User({ displayName, email, password });
    await newUser.save();

    res.status(201).json({ message: "Signup successful", userId: newUser._id });
  } catch (error) {
    console.error("Signup Error:", error);
    res.status(500).json({ message: "Server error during signup" });
  }
});

app.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ message: "Email and password are required." });

    const user = await User.findOne({ email });
    if (!user || user.password !== password)
      return res.status(401).json({ message: "Invalid credentials" });

    user.lastLogin = new Date();
    await user.save();

    const loginRecord = new LoginHistory({ userId: user._id, email: user.email });
    await loginRecord.save();

    res.status(200).json({
      message: "Login successful",
      userId: user._id,
      displayName: user.displayName,
      lastLogin: user.lastLogin,
      loginRecordId: loginRecord._id,
    });
  } catch (err) {
    console.error("Login Error:", err);
    res.status(500).json({ message: "Server error during login" });
  }
});

app.post("/auth/logout", async (req, res) => {
  try {
    res.status(200).json({ message: "Logged out successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

app.post("/auth/forgot", async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });

    res.status(200).json({ message: "Password reset link sent (mocked)" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Error sending reset link" });
  }
});

// --------------------
// Impact Metrics
// --------------------
app.get("/user/:id/impact", async (req, res) => {
  try {
    const userId = req.params.id;

    const plantsPlanted = await Plant.countDocuments({ userId });
    const tasksCompleted = await Task.countDocuments({ userId, status: "done" });
    const co2PerPlant = 1.5;
    const co2Absorbed = plantsPlanted * co2PerPlant;
    const communityPosts = await GrovePost.countDocuments({ userId });

    res.status(200).json({
      plantsPlanted,
      tasksCompleted,
      co2Absorbed,
      communityPosts,
    });
  } catch (err) {
    console.error("❌ Error fetching impact metrics:", err);
    res.status(500).json({ message: "Server error fetching impact metrics" });
  }
});

// --------------------
// Bud & Basket Marketplace Routes
// --------------------

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
    console.error("Cart Add Error:", err);
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
    console.error("Wishlist Error:", err);
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
    console.error("Order Create Error:", err);
    res.status(500).json({ message: "Failed to place order", error: err.message });
  }
});

// --------------------
// Server Startup
// --------------------
const PORT = 4000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);

  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === "IPv4" && !iface.internal) {
        console.log(`🌐 Accessible at: http://${iface.address}:${PORT}`);
      }
    }
  }
});
