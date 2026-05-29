var express = require('express');
var router = express.Router();
const db      = require('../config/db');
const { verifyToken, requireAdmin } = require('../middleware/auth');


router.post('/', verifyToken, async (req, res) => {
  const conn = await db.getConnection();
  try {
    const { weapon_id, quantity } = req.body;

    if (!weapon_id || !quantity) {
      return res.status(400).json({ success: false, message: 'weapon_id and quantity are required.' });
    }
    if (parseInt(quantity) < 1) {
      return res.status(400).json({ success: false, message: 'Quantity must be at least 1.' });
    }

    await conn.beginTransaction();

    const [weaponRows] = await conn.query('SELECT * FROM weapons WHERE id = ? FOR UPDATE', [weapon_id]);
    if (weaponRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ success: false, message: 'Weapon not found.' });
    }

    const weapon = weaponRows[0];
    const qty    = parseInt(quantity);

    if (weapon.stock < qty) {
      await conn.rollback();
      return res.status(400).json({ success: false, message: `Insufficient stock. Available: ${weapon.stock}` });
    }

    const totalPrice = parseFloat(weapon.price) * qty;

    const [result] = await conn.query(
      'INSERT INTO orders (user_id, weapon_id, quantity, total_price, status) VALUES (?, ?, ?, ?, ?)',
      [req.user.id, weapon_id, qty, totalPrice, 'confirmed']
    );

    await conn.query('UPDATE weapons SET stock = stock - ? WHERE id = ?', [qty, weapon_id]);

    await conn.commit();

    const [order] = await conn.query(
      `SELECT o.*, w.name AS weapon_name, w.type AS weapon_type, w.image_url
       FROM orders o JOIN weapons w ON w.id = o.weapon_id
       WHERE o.id = ?`,
      [result.insertId]
    );

    return res.status(201).json({ success: true, message: 'Order placed successfully.', data: order[0] });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  } finally {
    conn.release();
  }
});

router.get('/my', verifyToken, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT o.*, w.name AS weapon_name, w.type AS weapon_type, w.image_url
       FROM orders o
       JOIN weapons w ON w.id = o.weapon_id
       WHERE o.user_id = ?
       ORDER BY o.ordered_at DESC`,
      [req.user.id]
    );
    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ── GET /api/orders ───────────────────────────────────────────────────────────
// Admin only — view all orders
router.get('/', verifyToken, requireAdmin, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT o.*, u.name AS user_name, u.email AS user_email,
              w.name AS weapon_name, w.type AS weapon_type
       FROM orders o
       JOIN users   u ON u.id = o.user_id
       JOIN weapons w ON w.id = o.weapon_id
       ORDER BY o.ordered_at DESC`
    );
    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

module.exports = router;
