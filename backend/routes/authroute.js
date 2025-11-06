import express from "express";
import nodemailer from "nodemailer";
import crypto from "crypto";
import User from "./models/User.js"; // your MongoDB user model

const router = express.Router();

router.post("/forgot", async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "No account with that email" });
    }

    // Generate token
    const token = crypto.randomBytes(32).toString("hex");
    user.resetToken = token;
    user.tokenExpiry = Date.now() + 3600000; // 1 hour expiry
    await user.save();

    // Create email transporter
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "yourgmail@gmail.com",
        pass: "your-app-password", // not your real Gmail password!
      },
    });

    const resetLink = `http://localhost:5000/reset/${token}`;

    const mailOptions = {
      from: '"GreenTalkies Support" <yourgmail@gmail.com>',
      to: user.email,
      subject: "Password Reset - GreenTalkies",
      html: `
        <h2>Hello ${user.name},</h2>
        <p>Click the link below to reset your password:</p>
        <a href="${resetLink}" style="color:#4C8C45;">Reset Password</a>
        <p>This link will expire in 1 hour.</p>
      `,
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: "Reset link sent to your email" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Error sending email" });
  }
});

export default router;
