import express from "express";
import { getAllItems, createItem, updateItem, deleteItem } from "../controllers/item-controllers";

const router = express.Router();

router.get('/items', getAllItems);
router.post('/items', createItem);
router.put('/items/:id', updateItem);
router.delete('/items/:id', deleteItem);

export default router;
