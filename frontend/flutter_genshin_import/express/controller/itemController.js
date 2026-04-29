const db = require('../config/db');

exports.getAllItems = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM items');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.createItem = async (req, res) => {
    try {
        const { name, category, item_type, description, stock, price } = req.body;
        const imageUrl = req.file ? `http://localhost:3000/uploads/${req.file.filename}` : null;

        const [result] = await db.execute(
            'INSERT INTO items (name, category, item_type, description, stock, image_url, price) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [name, category, item_type, description, stock, imageUrl, price]
        );

        res.status(201).json({ message: "Item berhasil ditambah", id: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};