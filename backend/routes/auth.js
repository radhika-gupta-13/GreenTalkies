import express from "express";
import User from "../models/User.js";

const router = express.Router();

// 🟢 Login API
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password)
    return res.status(400).json({ message: "Email and password required" });

  try {
    const user = await User.findOne({ email });
    if (!user)
      return res.status(404).json({ message: "User not found" });

    // ⚠️ Simple password match (plain text for now)
    // For production, use bcrypt.compare() if passwords are hashed
    if (user.password !== password)
      return res.status(401).json({ message: "Invalid password" });

    res.json({
      success: true,
      userId: user._id,
      displayName: user.displayName,
      email: user.email,
    });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

export default router;
