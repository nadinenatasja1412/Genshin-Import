import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import {prisma} from '../lib/prisma';

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email dan password wajib diisi!" });
    }
    const user = await prisma.users.findUnique({
      where: { email: email }
    });

    if (!user) {
      return res.status(401).json({ message: "Email atau Password salah!" });
    }

    const isPasswordMatch = await bcrypt.compare(password, user.password);

    if (!isPasswordMatch) {
      return res.status(401).json({ message: "Email atau Password salah!" });
    }

    return res.status(200).json({
      message: "Login berhasil!",
      user: {
        id: user.id,
        username: user.username,
        role: user.role
      }
    });

  } catch (error: any) {
    console.error("DEBUG LOGIN ERROR:", error);
    return res.status(500).json({ 
      message: "Terjadi kesalahan server", 
      error: error.message 
    });
  }
};