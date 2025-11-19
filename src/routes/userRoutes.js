import express from "express";
import { getMyProfile, getProfileById } from "../controllers/userController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.get("/me", protect, getMyProfile);
router.get("/:id", getProfileById);

export default router;
