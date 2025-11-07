import express from "express";
import multer from "multer";
import path from "path";
import fs from "fs";

const router = express.Router();

// ======================================================
//             FILE UPLOAD SETUP (MULTER)
// ======================================================
const UPLOAD_FOLDER = "uploads";
if (!fs.existsSync(UPLOAD_FOLDER)) fs.mkdirSync(UPLOAD_FOLDER);

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_FOLDER),
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});

const fileFilter = (req, file, cb) => {
  const allowed = ["image/jpeg", "image/png", "image/jpg"];
  if (allowed.includes(file.mimetype)) cb(null, true);
  else cb(new Error("Only image files are allowed!"), false);
};

const upload = multer({ storage, fileFilter });

// ======================================================
//             PLANT DIAGNOSIS ROUTE
// ======================================================
router.post("/diagnose", upload.single("image"), async (req, res) => {
  try {
    const query = req.body.query;
    if (query && query.trim() !== "") {
      const result = getPlantDiagnosisByKeyword(query);
      return res.json({
        diagnosis: result.diagnosis,
        treatment: result.treatment,
        type: "manual",
      });
    }

    if (!req.file)
      return res.status(400).json({ error: "No image provided for diagnosis" });

    // Simulated AI output for plant disease
    const diagnosis = "Fungal Leaf Spot";
    const treatment =
      "Remove infected leaves, avoid overhead watering, and spray a mix of cinnamon water or diluted neem oil to prevent further infection.";

    res.json({ diagnosis, treatment, type: "image" });
  } catch (error) {
    console.error("Diagnosis error:", error);
    res.status(500).json({ error: error.message });
  }
});

// ======================================================
//             SOIL DIAGNOSIS ROUTE
// ======================================================
router.post("/soil-diagnose", upload.single("image"), async (req, res) => {
  try {
    const query = req.body.query;
    if (query && query.trim() !== "") {
      const result = getSoilDiagnosisByKeyword(query);
      return res.json({
        diagnosis: result.diagnosis,
        treatment: result.treatment,
        type: "manual",
      });
    }

    if (!req.file)
      return res.status(400).json({ error: "No image provided for soil diagnosis" });

    // Simulated AI result for soil photo
    const diagnosis = "Compacted or nutrient-depleted soil";
    const treatment =
      "Loosen top soil and mix with organic compost. Add crushed eggshells or banana peel fertilizer for mineral boost.";

    res.json({ diagnosis, treatment, type: "image" });
  } catch (error) {
    console.error("Soil Diagnosis error:", error);
    res.status(500).json({ error: error.message });
  }
});

// ======================================================
//        MANUAL QUERY HELPERS (Organic Tips)
// ======================================================
function getPlantDiagnosisByKeyword(keyword) {
  keyword = keyword.toLowerCase();

  if (keyword.includes("yellow")) {
    return {
      diagnosis: "Nitrogen deficiency or overwatering",
      treatment:
        "Allow soil to dry slightly before watering. Add compost tea or organic fertilizer rich in nitrogen like banana peel or neem cake.",
    };
  }

  if (keyword.includes("spots")) {
    return {
      diagnosis: "Leaf spot disease (fungal/bacterial)",
      treatment:
        "Remove affected leaves and spray turmeric or cinnamon water. Repeat every 3 days until leaves recover.",
    };
  }

  if (keyword.includes("drooping") || keyword.includes("wilt")) {
    return {
      diagnosis: "Root rot or water imbalance",
      treatment:
        "Improve drainage and use cinnamon powder at root base. Avoid frequent watering.",
    };
  }

  if (keyword.includes("insect") || keyword.includes("pest")) {
    return {
      diagnosis: "Aphid or mealybug infestation",
      treatment:
        "Spray neem oil or soap water every morning for a week. Use garlic or chili spray for natural pest deterrence.",
    };
  }

  return {
    diagnosis: "General plant stress",
    treatment:
      "Provide morning sunlight and water consistently. Spray diluted aloe vera or coconut water for gentle recovery.",
  };
}

function getSoilDiagnosisByKeyword(keyword) {
  keyword = keyword.toLowerCase();

  if (keyword.includes("dry")) {
    return {
      diagnosis: "Low moisture content",
      treatment:
        "Add organic mulch (like dried leaves or coconut husk) to retain water. Water deeply but less frequently.",
    };
  }

  if (keyword.includes("white") || keyword.includes("mold")) {
    return {
      diagnosis: "Fungal growth or salt deposit",
      treatment:
        "Remove top 2 cm of affected soil, add fresh compost, and spray cinnamon water. Improve ventilation and reduce watering.",
    };
  }

  if (keyword.includes("hard") || keyword.includes("compact")) {
    return {
      diagnosis: "Soil compaction",
      treatment:
        "Loosen soil with a stick or fork. Mix in sand and compost to improve aeration naturally.",
    };
  }

  if (keyword.includes("smell") || keyword.includes("sour")) {
    return {
      diagnosis: "Anaerobic or waterlogged soil",
      treatment:
        "Add dry compost and let the soil air out. Sprinkle cinnamon powder to prevent fungal activity.",
    };
  }

  return {
    diagnosis: "General soil imbalance",
    treatment:
      "Mix organic compost and coconut fiber to restore balance. Add a few drops of diluted vinegar if pH is too high.",
  };
}

export default router;
