import express from "express";
import { login } from "../controllers/login-controllers";
import { register } from "../controllers/register-controllers";
import { getAllItems, createItem, updateItem, deleteItem } from "../controllers/item-controllers";

const router = express.Router();

router.get('/items', getAllItems);
router.post('/items', createItem);
router.put('/items/:id', updateItem);
router.delete('/items/:id', deleteItem);
router.post("/register", register);
router.post("/login", login);

export default router;
