import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

export const dbConfig = mysql.createPool({
  host: process.env.DBHOST,
  user: process.env.DBUSER,
  password: process.env.DBPASSWORD,
  database: process.env.DBDATABASENAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

async function testConnection() {
  try {
    const connection = await dbConfig.getConnection();
    console.log("✅ MySQL Connected ke PiyoPlate DB!");
    connection.release(); 
  } catch (err: any) {
    console.error("❌ Gagal Konek Database!");
    console.error("Kode Error:", err.code);
    console.error("Pesan:", err.message);
  }
}

testConnection();