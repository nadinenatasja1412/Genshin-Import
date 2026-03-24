import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

export const buyItem = async (req: Request, res: Response) => {
  try {
    const { userId, itemId, quantity } = req.body;

    if (!userId || !itemId || !quantity || quantity <= 0) {
      return res.status(400).json({ message: "Data pembelian tidak valid!" });
    }

    const item = await prisma.items.findUnique({
      where: { id: Number(itemId) }
    });

    if (!item) {
      return res.status(404).json({ message: "Item tidak ditemukan!" });
    }

    if (item.stock < quantity) {
      return res.status(400).json({ message: `Stok tidak cukup! Sisa: ${item.stock}` });
    }

    const totalHarga = itemId.price * quantity;

    const result = await prisma.$transaction(async (tx) => {
      const updatedItem = await tx.items.update({
        where: { id: itemId },
        data: {
          stock: {
            decrement: quantity 
          }
        }
      });

      const newTransaction = await tx.transaction.create({
        data: {
          userId: userId,
          itemId: itemId,
          quantity: quantity,
          totalPrice: totalHarga
        }
      });

      return { updatedItem, newTransaction };
    });

    return res.status(201).json({
      message: "Pembelian berhasil!",
      detail: result.newTransaction
    });

  } catch (error: any) {
    console.error("BUY ERROR:", error);
    return res.status(500).json({ message: "Gagal memproses pembelian", error: error.message });
  }
};