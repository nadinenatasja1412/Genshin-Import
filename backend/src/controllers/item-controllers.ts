import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getAllItems = async (req: Request, res: Response) => {
  const items = await prisma.items.findMany();
  res.json(items);
};

export const createItem = async (req: Request, res: Response) => {
  try {
    const { name, category, item_type, description, stock, price } = req.body;
    
    // Ambil nama file dari multer
    const file = req.file;
    if (!file) return res.status(400).json({ message: "Wajib upload gambar!" });

    // Buat URL lengkapnya
    const imageUrl = `http://localhost:3000/uploads/${file.filename}`;

    const newItem = await prisma.items.create({
      data: {
        name,
        category,
        item_type,
        description,
        stock: Number(stock),
        price: parseFloat(price),
        image_url: imageUrl // Simpan URL ke DB
      }
    });

    res.status(201).json(newItem);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
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

export const deleteItem = async (req: Request, res: Response) => {
  const { id } = req.params;
  await prisma.items.delete({ where: { id: Number(id) } });
  res.json({ message: "Item berhasil dihapus" });
};