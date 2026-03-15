import { Request, Response } from "express";
import { dbConfig } from "../configdb/db-config";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

const SECRET = "rahasia";

export const login = (req: Request, res: Response) => {
  const { email, password } = req.body;

  dbConfig.query(
    "SELECT * FROM users WHERE email = ?",
    [email],
    async (err, result: any) => {
      if (result.length === 0)
        return res.json({ message: "User tidak ada" });

      const user = result[0];

      const valid = await bcrypt.compare(password, user.password);

      if (!valid)
        return res.json({ message: "Password salah" });

      const token = jwt.sign(
        { id: user.id, email: user.email },
        SECRET
      );

      res.json({
        message: "Login sukses",
        token
      });
    }
  );
};
