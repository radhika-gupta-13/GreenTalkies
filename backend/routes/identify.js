import express from "express";
import multer from "multer";
import fs from "fs";
import { GoogleGenerativeAI } from "@google/generative-ai";

const router = express.Router();
const upload = multer({ 
  dest: "uploads/",
  fileFilter: (req, file, cb) => {
    // Accept only images
    if (!file.mimetype.startsWith("image/")) {
      return cb(new Error("Only image files are allowed!"), false);
    }
    cb(null, true);
  }
});

// Initialize Gemini model once
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

// Utility function to convert image to base64
const getBase64 = (filePath) => {
  const buffer = fs.readFileSync(filePath);
  return buffer.toString("base64");
};

// ----------------- Identify Plant -----------------
router.post("/identify", upload.single("image"), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No image uploaded" });

  const filePath = req.file.path;
  try {
    const base64Image = getBase64(filePath);
    const prompt = "Identify this plant. Provide common name, scientific name, and short description.";

    const result = await model.generateContent([
      { inlineData: { mimeType: req.file.mimetype, data: base64Image } },
      { text: prompt },
    ]);

    res.json({ result: result.response.text() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message || "Plant identification failed" });
  } finally {
    // Clean up uploaded file
    fs.unlink(filePath, (err) => err && console.error("File cleanup failed:", err));
  }
});

// ----------------- Diagnose Plant -----------------
router.post("/diagnose", upload.single("image"), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No image uploaded" });

  const filePath = req.file.path;
  try {
    const base64Image = getBase64(filePath);
    const prompt = `
      Examine this plant and identify any visible diseases, pests, or deficiencies.
      If it looks healthy, say so and provide a short care tip.
    `;

    const result = await model.generateContent([
      { inlineData: { mimeType: req.file.mimetype, data: base64Image } },
      { text: prompt },
    ]);

    res.json({ diagnosis: result.response.text() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message || "Diagnosis failed" });
  } finally {
    // Clean up uploaded file
    fs.unlink(filePath, (err) => err && console.error("File cleanup failed:", err));
  }
});

export default router;
