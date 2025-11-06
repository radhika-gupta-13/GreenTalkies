import express from "express";
import Plant from "../models/Plant.js";
import multer from "multer";
import path from "path";
import fs from "fs";

const router = express.Router();

// ----------------------------
// Setup uploads folder
// ----------------------------
const UPLOAD_FOLDER = "uploads";
if (!fs.existsSync(UPLOAD_FOLDER)) fs.mkdirSync(UPLOAD_FOLDER);

// Serve uploaded images as static files
router.use("/uploads", express.static(path.join(path.resolve(), UPLOAD_FOLDER)));

// Multer configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_FOLDER),
  filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });

// ----------------------------
// Helper: format plant with full image URL
// ----------------------------
function formatPlant(plant, req) {
  const formatted = plant.toObject();
  if (formatted.imageUrl && !formatted.imageUrl.startsWith("http")) {
    const host = `${req.protocol}://${req.get("host")}`;
    formatted.imageUrl = `${host}/${formatted.imageUrl}`;
  }
  return formatted;
}

// ----------------------------
// GET all plants for a specific user
// ----------------------------
router.get("/user/:userId", async (req, res) => {
  try {
    const plants = await Plant.find({ userId: req.params.userId });
    const formattedPlants = plants.map((p) => formatPlant(p, req));
    res.status(200).json(formattedPlants);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ----------------------------
// GET single plant by ID
// ----------------------------
router.get("/:plantId", async (req, res) => { 
  try {
    const plant = await Plant.findById(req.params.plantId);
    if (!plant) return res.status(404).json({ message: "Plant not found" });
    res.status(200).json(formatPlant(plant, req));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ----------------------------
// POST a new plant
// ----------------------------
router.post("/", async (req, res) => {
  try {
    const newPlant = new Plant(req.body);
    await newPlant.save();
    res.status(201).json(formatPlant(newPlant, req));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ----------------------------
// DELETE a plant by ID
// ----------------------------
router.delete("/:plantId", async (req, res) => {
  try {
    const deletedPlant = await Plant.findByIdAndDelete(req.params.plantId);
    if (!deletedPlant) return res.status(404).json({ message: "Plant not found" });
    res.status(200).json({ message: "Plant deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ----------------------------
// PUT update plant by ID
// ----------------------------
router.put("/:plantId", async (req, res) => {
  try {
    const updatedPlant = await Plant.findByIdAndUpdate(
      req.params.plantId,
      req.body,
      { new: true, runValidators: true }
    );
    if (!updatedPlant) return res.status(404).json({ message: "Plant not found" });
    res.status(200).json(formatPlant(updatedPlant, req));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ----------------------------
// PUT upload/update plant image
// ----------------------------
router.put("/:plantId/image", upload.single("image"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No image uploaded" });

    const imagePath = `uploads/${req.file.filename}`; // store relative path
    const updatedPlant = await Plant.findByIdAndUpdate(
      req.params.plantId,
      { imageUrl: imagePath },
      { new: true }
    );

    if (!updatedPlant) return res.status(404).json({ message: "Plant not found" });

    // Return full URL to frontend
    const host = `${req.protocol}://${req.get("host")}`;
    const formattedPlant = updatedPlant.toObject();
    formattedPlant.imageUrl = `${host}/${imagePath}`;

    res.status(200).json(formattedPlant);
  } catch (err) {
    console.log("❌ Error uploading image:", err);
    res.status(500).json({ message: err.message });
  }
});

export default router;