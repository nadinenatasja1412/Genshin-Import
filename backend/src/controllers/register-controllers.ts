import { Request, Response } from "express";
import { dbConfig } from "../configdb/db-config";
import bcrypt from "bcryptjs";

const SECRET = "rahasia";

export const register = async (req: Request, res: Response) => {
  const { name, email, password } = req.body;

  const hash = await bcrypt.hash(password, 10);

  dbConfig.query(
    "INSERT INTO users (name, email, password) VALUES (?, ?, ?)",
    [name, email, hash],
    (err) => {
      if (err) return res.json({ message: "Email sudah ada" });

      res.json({ message: "Register sukses" });
    }
  );
};