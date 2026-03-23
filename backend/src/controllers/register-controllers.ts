import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const register = async (req: Request, res: Response) => {
  try {
    const { username, email, password, full_name, role } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ message: "Username, Email, dan Password wajib diisi!" });
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const newUser = await prisma.users.create({
      data: {
        username,
        email,
        password: hashedPassword,
        full_name,
        role: role || 'user',
      },
    });

    return res.status(201).json({
      message: "Registrasi berhasil!",
      data: { 
        username: newUser.username, 
        email: newUser.email, 
        role: newUser.role 
      }
    });

  } catch (error: any) {
    console.error("DEBUG REGISTER ERROR:", error);

    // Prisma punya kode error sendiri (P2002 adalah Unique Constraint)
    if (error.code === 'P2002') {
      return res.status(400).json({ message: "Username atau Email sudah terdaftar!" });
    }

    return res.status(500).json({ 
      message: "Terjadi kesalahan server", 
      error: error.message 
    });
  }
};