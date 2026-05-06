const db = require('../config/db');

exports.buyItem = async (req, res) => {
    // Kita mulai koneksi khusus untuk transaction
    const connection = await db.getConnection();
    
    try {
        const { user_id, item_id, quantity } = req.body;

        // 1. Mulai Transaction
        await connection.beginTransaction();

        // 2. Cek Stok dan Harga Barang
        const [items] = await connection.execute(
            'SELECT stock, price FROM items WHERE id = ?', 
            [item_id]
        );

        if (items.length === 0) {
            throw new Error("Item tidak ditemukan di Teyvat!");
        }

        const item = items[0];
        if (item.stock < quantity) {
            throw new Error("Stok tidak mencukupi untuk pesanan ini.");
        }

        const totalPrice = item.price * quantity;

        // 3. Kurangi Stok Barang
        await connection.execute(
            'UPDATE items SET stock = stock - ? WHERE id = ?',
            [quantity, item_id]
        );

        // 4. Catat ke Tabel Transactions
        const [result] = await connection.execute(
            'INSERT INTO transactions (user_id, item_id, quantity, total_price) VALUES (?, ?, ?, ?)',
            [user_id, item_id, quantity, totalPrice]
        );

        // 5. Jika semua lancar, simpan permanen (Commit)
        await connection.commit();

        res.status(201).json({
            message: "Pembelian berhasil!",
            transaction_id: result.insertId,
            total_spent: totalPrice
        });

    } catch (error) {
        // Jika ada yang salah, batalkan semua perubahan (Rollback)
        await connection.rollback();
        res.status(400).json({ message: error.message });
    } finally {
        // Kembalikan koneksi ke pool
        connection.release();
    }
};

exports.getTransactionHistory = async (req, res) => {
    try {
        const [rows] = await db.execute(`
            SELECT t.*, i.name as item_name, u.username 
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.user_id = u.id
            ORDER BY t.purchase_date DESC
        `);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};