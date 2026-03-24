import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getAllItems = async (req: Request, res: Response) => {
  const items = await prisma.items.findMany();
  res.json(items);
};

export const createItem = async (req: Request, res: Response) => {
  const { name, category, itemType, description, stock, image, price } = req.body;
  try {
    const newItem = await prisma.items.create({
      data: { name, category, item_type: itemType, description, stock, image_url: image, price }
    });
    res.status(201).json(newItem);
  } catch (error) {
    res.status(500).json({ error: "Gagal menambah item" });
  }
};

// --- UPDATE (Khusus Admin) ---
export const updateItem = async (req: Request, res: Response) => {
  const { id } = req.params;
  const data = req.body;
  const updated = await prisma.items.update({
    where: { id: Number(id) },
    data: data
  });
  res.json(updated);
};

// --- DELETE (Khusus Admin) ---
export const deleteItem = async (req: Request, res: Response) => {
  const { id } = req.params;
  await prisma.items.delete({ where: { id: Number(id) } });
  res.json({ message: "Item berhasil dihapus" });
};