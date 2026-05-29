var express = require('express');
var router = express.Router();

const db      = require('../config/db');
const { verifyToken, requireAdmin } = require('../middleware/auth');

router.get('/', async (req, res) => {
  try {
    const { search = '', type = '' } = req.query;
    let sql    = 'SELECT * FROM weapons WHERE 1=1';
    const params = [];

    if (search) {
      sql += ' AND (name LIKE ? OR description LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }
    if (type) {
      sql += ' AND type = ?';
      params.push(type);
    }
    sql += ' ORDER BY created_at DESC';

    const [rows] = await db.query(sql, params);
    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM weapons WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Weapon not found.' });
    }
    return res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ── POST /api/weapons ─────────────────────────────────────────────────────────
// Admin only — create weapon
router.post('/', verifyToken, requireAdmin, async (req, res) => {
  try {
    const { name, type, description, stock, image_url, price } = req.body;

    // Validation
    const validTypes = ['Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'];
    if (!name || !type || !description || stock === undefined || price === undefined) {
      return res.status(400).json({ success: false, message: 'All fields are required.' });
    }
    if (!validTypes.includes(type)) {
      return res.status(400).json({ success: false, message: `Type must be one of: ${validTypes.join(', ')}` });
    }
    if (parseInt(stock) < 0) {
      return res.status(400).json({ success: false, message: 'Stock cannot be negative.' });
    }
    if (parseFloat(price) <= 0) {
      return res.status(400).json({ success: false, message: 'Price must be greater than zero.' });
    }

    const [result] = await db.query(
      'INSERT INTO weapons (name, type, description, stock, image_url, price) VALUES (?, ?, ?, ?, ?, ?)',
      [name, type, description, parseInt(stock), image_url || null, parseFloat(price)]
    );

    const [newWeapon] = await db.query('SELECT * FROM weapons WHERE id = ?', [result.insertId]);
    return res.status(201).json({ success: true, message: 'Weapon created.', data: newWeapon[0] });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

router.put('/:id', verifyToken, requireAdmin, async (req, res) => {
  try {
    const { name, type, description, stock, image_url, price } = req.body;

    const validTypes = ['Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'];
    if (!name || !type || !description || stock === undefined || price === undefined) {
      return res.status(400).json({ success: false, message: 'All fields are required.' });
    }
    if (!validTypes.includes(type)) {
      return res.status(400).json({ success: false, message: `Type must be one of: ${validTypes.join(', ')}` });
    }
    if (parseInt(stock) < 0) {
      return res.status(400).json({ success: false, message: 'Stock cannot be negative.' });
    }
    if (parseFloat(price) <= 0) {
      return res.status(400).json({ success: false, message: 'Price must be greater than zero.' });
    }

    const [existing] = await db.query('SELECT id FROM weapons WHERE id = ?', [req.params.id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Weapon not found.' });
    }

    await db.query(
      'UPDATE weapons SET name=?, type=?, description=?, stock=?, image_url=?, price=? WHERE id=?',
      [name, type, description, parseInt(stock), image_url || null, parseFloat(price), req.params.id]
    );

    const [updated] = await db.query('SELECT * FROM weapons WHERE id = ?', [req.params.id]);
    return res.json({ success: true, message: 'Weapon updated.', data: updated[0] });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ── DELETE /api/weapons/:id ───────────────────────────────────────────────────
// Admin only — delete weapon
router.delete('/:id', verifyToken, requireAdmin, async (req, res) => {
  try {
    const [existing] = await db.query('SELECT id FROM weapons WHERE id = ?', [req.params.id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Weapon not found.' });
    }

    await db.query('DELETE FROM weapons WHERE id = ?', [req.params.id]);
    return res.json({ success: true, message: 'Weapon deleted.' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

module.exports = router;
