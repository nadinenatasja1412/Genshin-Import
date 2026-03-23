
import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { dbConfig } from '../configdb/db-config';

export const register = async (req: Request, res: Response) => {
  try {
    const { username, email, password, full_name, role } = req.body;
    if (!username || !email || !password) {
      return res.status(400).json({ message: "Username, Email, dan Password wajib diisi!" });
    }
    
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const userRole = role || 'user';
    
    const query = `INSERT INTO MsUser (username, email, password, full_name, role) VALUES (?, ?, ?, ?, ?)`;
    
    await dbConfig.execute(query, [username, email, hashedPassword, full_name, userRole]);

    return res.status(201).json({
      message: "Registrasi berhasil!",
      data: { username, email, role: userRole }
    });

  } catch (error: any) {
    console.error("DEBUG REGISTER ERROR:", error);

    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ message: "Username atau Email sudah terdaftar!" });
    }

    if (error.code === 'ER_NO_SUCH_TABLE') {
      return res.status(500).json({ message: "Tabel MsUser belum dibuat di database." });
    }

    return res.status(500).json({ 
      message: "Terjadi kesalahan server", 
      error: error.message 
    });
  }
};
