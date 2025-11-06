import mongoose from "mongoose";

const loginHistorySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  email: String,
  loginAt: { type: Date, default: Date.now },
});

export default mongoose.models.LoginHistory || mongoose.model("LoginHistory", loginHistorySchema);
