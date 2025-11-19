import express from "express";
import * as authController from "../controllers/authController.js";

const router = express.Router();

router.post("/signup", authController.signUp);
router.post("/signin", authController.signIn);
router.post("/signout", authController.signOut);
// Dev seed endpoint to create Usuario / Perfil / Perfil_empresa for testing
router.post("/seed-company", authController.seedCompany);

export default router;
