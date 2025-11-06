import mongoose from "mongoose";

const plantSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  name: { type: String, required: true },
  nickname: { type: String, required: true },
  healthStatus: { type: String, default: "Recently Added" },
  nextAction: { type: String, default: "Check in 1 week" },
  imageUrl: { type: String, default: "assets/default_plant.jpg" },
}, { timestamps: true });

export default mongoose.model("Plant", plantSchema);
