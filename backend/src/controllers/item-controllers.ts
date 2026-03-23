import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getAllItems = async (req: Request, res: Response) => {
  const items = await prisma.item.findMany();
  res.json(items);
};

export const createItem = async (req: Request, res: Response) => {
  const { name, category, itemType, description, stock, image, price } = req.body;
  try {
    const newItem = await prisma.item.create({
      data: { name, category, itemType, description, stock, image, price }
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
  const updated = await prisma.item.update({
    where: { id: Number(id) },
    data: data
  });
  res.json(updated);
};

// --- DELETE (Khusus Admin) ---
export const deleteItem = async (req: Request, res: Response) => {
  const { id } = req.params;
  await prisma.item.delete({ where: { id: Number(id) } });
  res.json({ message: "Item berhasil dihapus" });
};