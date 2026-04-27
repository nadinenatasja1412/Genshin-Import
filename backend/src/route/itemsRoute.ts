import express from "express";
import { getAllItems, createItem, updateItem, deleteItem } from "../controllers/item-controllers";
import { upload } from "../middleware/uploads";

const router = express.Router();

router.get('/items', getAllItems);
router.post('/items', createItem);
router.put('/items/:id', updateItem);
router.delete('/items/:id', deleteItem);
router.post('/', upload.single('image'), createItem);

export default router;
