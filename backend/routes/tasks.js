import express from "express";
import Task from "../models/Task.js";

const router = express.Router();

// -----------------------------
// GET all tasks for a specific user
// -----------------------------
router.get("/:userId", async (req, res) => {
  try {
    const tasks = await Task.find({ userId: req.params.userId });
    res.status(200).json(tasks);
  } catch (err) {
    console.error("Error fetching tasks:", err);
    res.status(500).json({ message: "Error fetching tasks" });
  }
});

// -----------------------------
// POST add a new task
// -----------------------------
router.post("/", async (req, res) => {
  try {
    const { userId, plantName, task, time } = req.body;
    if (!userId || !plantName || !task) {
      return res
        .status(400)
        .json({ message: "User ID, plant name & task are required" });
    }

    const newTask = new Task({ userId, plantName, task, time });
    await newTask.save();

    res.status(201).json({ message: "Task created", task: newTask });
  } catch (err) {
    console.error("Error creating task:", err);
    res.status(500).json({ message: "Error creating task" });
  }
});

// -----------------------------
// PATCH update task status or time
// -----------------------------
router.patch("/:id/status", async (req, res) => {
  try {
    const { status, time } = req.body;
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: "Task not found" });

    if (status) task.status = status;
    if (time) task.time = time;
    task.updatedAt = new Date();
    await task.save();

    res.status(200).json({ message: "Task updated", task });
  } catch (err) {
    console.error("Error updating task:", err);
    res.status(500).json({ message: "Error updating task" });
  }
});

// -----------------------------
// DELETE a task
// -----------------------------
router.delete("/:id", async (req, res) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);
    if (!task) return res.status(404).json({ message: "Task not found" });
    res.status(200).json({ message: "Task deleted" });
  } catch (err) {
    console.error("Error deleting task:", err);
    res.status(500).json({ message: "Error deleting task" });
  }
});

export default router;
