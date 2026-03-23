import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { dbConfig } from '../configdb/db-config';

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: "Email dan password wajib diisi!" });
    }
    const query = `SELECT * FROM MsUser WHERE email = ? LIMIT 1`;
    
    const [rows]: any = await dbConfig.execute(query, [email]);
    
    if (rows.length === 0) {
      return res.status(401).json({ message: "Email atau Password salah!" });
    }

    const user = rows[0];
    const isPasswordMatch = await bcrypt.compare(password, user.password);

    if (!isPasswordMatch) {
      return res.status(401).json({ message: "Email atau Password salah!" });
    }
    return res.status(200).json({
      message: "Login berhasil!",
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
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