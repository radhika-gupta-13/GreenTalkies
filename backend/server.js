import express from "express";
import cors from "cors";
import mongoose from "mongoose";
import dotenv from "dotenv";
import bodyParser from "body-parser";
import os from "os";
import identifyRoute from "./routes/identify.js";
import Plant from "./models/Plant.js";
import Task from "./models/Task.js";
import GrovePost from "./models/GrovePost.js"; 
import path from "path";

// Routes
import taskRoutes from "./routes/tasks.js";
import authRoutes from "./routes/auth.js";
import plantRoutes from "./routes/plants.js";
import groveRoutes from "./routes/grove.js";

// Models
import User from "./models/User.js";
import LoginHistory from "./models/LoginHistory.js";

dotenv.config({ path: "./details.env" });

const app = express();

// --------------------
// Middleware
// --------------------
app.use(cors());
app.use(bodyParser.json());

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
// Routes
// --------------------
app.use("/tasks", taskRoutes);
app.use("/auth", authRoutes);
app.use("/plants", plantRoutes);
app.use("/api", identifyRoute);
app.use("/grove", groveRoutes);


// --------------------
// User Routes
// --------------------

// Fetch user by ID
app.get("/user/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update user profile
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
// Signup
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

// --------------------
// Login
// --------------------
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

// --------------------
// Logout (optional)
app.post("/auth/logout", async (req, res) => {
  try {
    res.status(200).json({ message: "Logged out successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// --------------------
// Forgot Password (mock)
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
// Impact Metrics Route
// --------------------
app.get("/user/:id/impact", async (req, res) => {
  try {
    const userId = req.params.id;

    // Total plants planted by this user
    const plantsPlanted = await Plant.countDocuments({ userId });

    // Total tasks completed (if you want to keep this)
    const tasksCompleted = await Task.countDocuments({ userId, status: "done" });

    // CO2 absorbed (example: each plant absorbs 1.5 kg CO2)
    const co2PerPlant = 1.5;
    const co2Absorbed = plantsPlanted * co2PerPlant;

    // Total community posts in Grove by this user
    const communityPosts = await GrovePost.countDocuments({ userId });

    res.status(200).json({
      plantsPlanted,
      tasksCompleted,
      co2Absorbed,
      communityPosts, // Added this field
    });
  } catch (err) {
    console.error("❌ Error fetching impact metrics:", err);
    res.status(500).json({ message: "Server error fetching impact metrics" });
  }
});

// --------------------
// Static Files for Uploads
// --------------------
app.use("/uploads", express.static(path.join('.', 'uploads')));
// Serve uploaded images
//app.use("/uploads", express.static(path.join(path.resolve(), "uploads")));

// Serve static assets (optional, for default images)
app.use("/assets", express.static(path.join(path.resolve(), "assets")));


// --------------------
// Server Startup
// --------------------
const PORT = 4000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);

  // Log local IPv4 addresses
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === "IPv4" && !iface.internal) {
        console.log(`🌐 Accessible at: http://${iface.address}:${PORT}`);
      }
    }
  }
});
