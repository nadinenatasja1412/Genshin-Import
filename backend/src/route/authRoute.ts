import express from "express";
import { login } from "../controllers/login-controllers";
import { register } from "../controllers/register-controllers";

const router = express.Router();

router.post("/register", register);
router.post("/login", login);

export default router;
