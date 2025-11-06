import mongoose from "mongoose";

const TaskSchema = new mongoose.Schema({
  // CRITICAL: Re-added for multi-user data separation
  userId: {
    type: String,
    required: true,
    index: true, // Indexed for faster querying by user
  },
  plantName: { 
    type: String, 
    required: true, 
    trim: true 
  },
  task: { 
    type: String, 
    required: true, 
    trim: true 
  },
  time: { 
    type: String, 
    default: "Not Scheduled" 
  },
  // Adopted user's preferred status field
  status: { 
    type: String, 
    enum: ["pending", "done", "snoozed"], 
    default: "pending" 
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  },
  updatedAt: { // Used by the PATCH route
    type: Date 
  },
});

TaskSchema.index({ plantName: 1 });

export default mongoose.models.Task || mongoose.model("Task", TaskSchema);
