import express from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import User from "../models/User.js";
import Plant from "../models/Plant.js"; // <--- import Plant
import GrovePost from "../models/GrovePost.js"; // <--- import GrovePost

const router = express.Router();

// ----------------------------
// Upload folder
// ----------------------------
const UPLOAD_FOLDER = path.resolve("uploads");
if (!fs.existsSync(UPLOAD_FOLDER)) fs.mkdirSync(UPLOAD_FOLDER);

// Serve uploaded images
router.use("/uploads", express.static(UPLOAD_FOLDER));

// ----------------------------
// Multer setup (user-ID-based filenames)
// ----------------------------
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_FOLDER),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `user-${req.params.id}${ext}`);
  },
});
const upload = multer({ storage });

// ----------------------------
// Helper: format user with full photo URL
// ----------------------------
function formatUser(user, req) {
  const formatted = user.toObject();
  if (formatted.photoUrl) {
    const host = `${req.protocol}://${req.get("host")}`;
    formatted.photoUrl = formatted.photoUrl.startsWith("http")
      ? formatted.photoUrl
      : `${host}${formatted.photoUrl}`;
  }
  return formatted;
}

// ----------------------------
// GET user by ID
// ----------------------------
router.get("/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });
    res.status(200).json(formatUser(user, req));
  } catch (err) {
    res.status(500).json({ message: "Error fetching user", error: err.message });
  }
});

// ----------------------------
// UPDATE user details
// ----------------------------
router.put("/:id", async (req, res) => {
  try {
    const { displayName, email, password } = req.body;
    const updateData = {};
    if (displayName) updateData.displayName = displayName;
    if (email) updateData.email = email;
    if (password) updateData.password = password;

    const updatedUser = await User.findByIdAndUpdate(req.params.id, updateData, { new: true });
    if (!updatedUser) return res.status(404).json({ message: "User not found" });

    res.status(200).json(formatUser(updatedUser, req));
  } catch (err) {
    res.status(500).json({ message: "Error updating user", error: err.message });
  }
});

// ----------------------------
// UPLOAD PROFILE PHOTO
// ----------------------------
router.post("/:id/photo", upload.single("photo"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No photo uploaded" });

    const user = await User.findById(req.params.id);
    if (!user) {
      fs.unlinkSync(req.file.path);
      return res.status(404).json({ message: "User not found" });
    }

    const photoPath = `/uploads/${req.file.filename}`;
    user.photoUrl = photoPath;
    await user.save();

    const host = `${req.protocol}://${req.get("host")}`;
    const fullPhotoUrl = `${host}${user.photoUrl}`;

    res.status(200).json({
      message: "Photo uploaded successfully",
      photoUrl: fullPhotoUrl,
    });
  } catch (err) {
    if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
    res.status(500).json({ message: "Error uploading photo", error: err.message });
  }
});

// ----------------------------
// Impact Metrics Route
// ----------------------------
router.get("/:id/impact", async (req, res) => { 
  try {
    const userId = req.params.id;

    const plantsPlanted = await Plant.countDocuments({ userId });
    const co2PerPlant = 1.5;
    const co2Absorbed = plantsPlanted * co2PerPlant;
    const communityPosts = await GrovePost.countDocuments({ userId });

    res.status(200).json({
      plantsPlanted,
      co2Absorbed,
      communityPosts,
    });
  } catch (err) {
    console.error("❌ Error fetching impact metrics:", err);
    res.status(500).json({ message: "Server error fetching impact metrics" });
  }
});

export default router;
