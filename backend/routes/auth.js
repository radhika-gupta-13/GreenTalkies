import express from "express";
import User from "../models/User.js";
import LoginHistory from "../models/LoginHistory.js"; // Make sure this model exists

const router = express.Router();

// -----------------------------
// 🟢 Signup API
// -----------------------------
router.post("/signup", async (req, res) => {
  try {
    const { displayName, email, password } = req.body;
    if (!displayName || !email || !password)
      return res.status(400).json({ message: "All fields are required." });

    const existingUser = await User.findOne({ email });
    if (existingUser)
      return res.status(409).json({ message: "Email already exists." });

    const newUser = new User({ displayName, email, password });
    await newUser.save();

    res.status(201).json({
      message: "Signup successful",
      userId: newUser._id,
      displayName: newUser.displayName,
      email: newUser.email,
    });
  } catch (error) {
    console.error("Signup Error:", error);
    res.status(500).json({ message: "Server error during signup" });
  }
});

// -----------------------------
// 🟢 Login API
// -----------------------------
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ message: "Email and password are required." });

    const user = await User.findOne({ email });
    if (!user || user.password !== password)
      return res.status(401).json({ message: "Invalid credentials" });

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    // Record login history (optional)
    const loginRecord = new LoginHistory({ userId: user._id, email: user.email });
    await loginRecord.save();

    res.status(200).json({
      message: "Login successful",
      userId: user._id,
      displayName: user.displayName,
      email: user.email,
      lastLogin: user.lastLogin,
      loginRecordId: loginRecord._id,
    });
  } catch (err) {
    console.error("Login Error:", err);
    res.status(500).json({ message: "Server error during login" });
  }
});

// -----------------------------
// 🟢 Logout API (dummy endpoint for frontend)
// -----------------------------
router.post("/logout", async (req, res) => {
  try {
    // If using tokens or sessions, you would invalidate them here
    res.status(200).json({ message: "Logged out successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// -----------------------------
// 🟢 Forgot Password API (mocked)
// -----------------------------
router.post("/forgot", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: "Email is required" });

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });

    // In production, send actual email
    res.status(200).json({ message: "Password reset link sent (mocked)" });
  } catch (err) {
    console.error("Forgot Password Error:", err);
    res.status(500).json({ message: "Server error sending reset link" });
  }
});

export default router;
