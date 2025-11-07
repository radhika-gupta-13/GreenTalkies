// backend/routes/diagnose.js
import express from "express";
import multer from "multer";
import fs from "fs";
import path from "path";

const router = express.Router();

// ---------------- MULTER SETUP ----------------
const UPLOAD_FOLDER = "uploads";
if (!fs.existsSync(UPLOAD_FOLDER)) fs.mkdirSync(UPLOAD_FOLDER);

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_FOLDER),
  filename: (req, file, cb) =>
    cb(null, Date.now() + "-" + file.originalname.replace(/\s+/g, "_")),
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith("image/")) cb(null, true);
  else cb(new Error("Only image files are allowed!"), false);
};

const upload = multer({ storage, fileFilter });

// ---------------- ORGANIC REMEDY DATABASE ----------------
const remedies = {
  "yellow leaves": {
    cause: "Overwatering or nitrogen deficiency",
    treatment: [
      "Let soil dry before next watering",
      "Add compost tea or banana peel fertilizer",
      "Avoid chemical fertilizers; use neem cake powder once a month",
    ],
  },
  "powdery mildew": {
    cause: "Fungal infection due to high humidity",
    treatment: [
      "Spray neem oil solution every 3 days",
      "Remove affected leaves",
      "Increase air circulation",
    ],
  },
  "leaf spot": {
    cause: "Fungal or bacterial leaf disease",
    treatment: [
      "Remove spotted leaves immediately",
      "Spray turmeric water (1 tsp in 1L water)",
      "Avoid overhead watering",
    ],
  },
  wilting: {
    cause: "Root rot or poor drainage",
    treatment: [
      "Repot with well-draining soil",
      "Add cinnamon powder at root base to prevent fungus",
      "Reduce watering frequency",
    ],
  },
  pest: {
    cause: "Aphids, mealybugs, or spider mites infestation",
    treatment: [
      "Spray neem oil every 2 days for a week",
      "Wipe leaves with diluted soap water",
      "Use garlic or chili spray as a natural repellent",
    ],
  },
};

// ---------------- HELPER: GET DIAGNOSIS ----------------
function getDiagnosisResult(queryOrImage, type = "plant") {
  const db = remedies; // same for soil/plant for now
  const key = queryOrImage?.toLowerCase() || "";

  const match = Object.keys(db).find((d) => key.includes(d)) || null;

  if (match) {
    return {
      name: match,
      cause: db[match].cause,
      organic_treatment: db[match].treatment,
    };
  }

  // fallback for unknown query/image
  return {
    name: "General Stress",
    cause: "Unknown issue or environmental stress",
    organic_treatment: [
      "Ensure adequate sunlight and airflow",
      "Use compost tea once a week",
      "Water only when top soil feels dry",
    ],
  };
}

// ---------------- PLANT DIAGNOSE ----------------
router.post("/diagnose", upload.single("image"), (req, res) => {
  try {
    const manualQuery = req.body.manualQuery || req.query.manualQuery;
    let diagnosis;

    if (manualQuery) {
      diagnosis = getDiagnosisResult(manualQuery, "plant");
    } else if (req.file) {
      // simulate image-based diagnosis
      diagnosis = getDiagnosisResult("powdery mildew", "plant");
    } else {
      return res.status(400).json({ error: "No image or query provided" });
    }

    res.json({ diagnosis });
  } catch (err) {
    console.error("Diagnosis Error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ---------------- SOIL DIAGNOSE ----------------
router.post("/soil-diagnose", upload.single("image"), (req, res) => {
  try {
    const manualQuery = req.body.manualQuery || req.query.manualQuery;
    let diagnosis;

    if (manualQuery) {
      diagnosis = getDiagnosisResult(manualQuery, "soil");
    } else if (req.file) {
      // simulate image-based soil diagnosis
      diagnosis = getDiagnosisResult("yellow leaves", "soil");
    } else {
      return res.status(400).json({ error: "No image or query provided" });
    }

    res.json({ diagnosis });
  } catch (err) {
    console.error("Soil Diagnosis Error:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
