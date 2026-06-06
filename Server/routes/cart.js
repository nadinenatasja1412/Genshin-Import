const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { verifyToken } = require('../middleware/middleware');

router.use(verifyToken);

router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT c.id AS id, c.user_id, c.weapon_id, c.quantity,
              w.name, w.type, w.description, w.stock, w.image_url, w.price
       FROM cart_items c
       JOIN weapons w ON w.id = c.weapon_id
       WHERE c.user_id = ?
       ORDER BY c.created_at DESC`,
      [req.user.id]
    );

    const cartItems = rows.map(row => ({
      id: row.id,
      user_id: row.user_id,
      weapon_id: row.weapon_id,
      quantity: row.quantity,
      weapon: {
        id: row.weapon_id,
        name: row.name,
        type: row.type,
        description: row.description,
        stock: row.stock,
        image_url: row.image_url,
        price: parseFloat(row.price),
      },
    }));

    return res.json({ success: true, data: cartItems });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { weapon_id, quantity } = req.body;
    if (!weapon_id || !quantity) {
      return res.status(400).json({ success: false, message: 'weapon_id and quantity are required.' });
    }
    const qty = parseInt(quantity, 10);
    if (qty < 1) {
      return res.status(400).json({ success: false, message: 'Quantity must be at least 1.' });
    }

    const [weaponRows] = await db.query('SELECT stock FROM weapons WHERE id = ?', [weapon_id]);
    if (weaponRows.length === 0) {
      return res.status(404).json({ success: false, message: 'Weapon not found.' });
    }
    if (weaponRows[0].stock < qty) {
      return res.status(400).json({ success: false, message: 'Requested quantity exceeds stock.' });
    }

    const [existingRows] = await db.query(
      'SELECT id, quantity FROM cart_items WHERE user_id = ? AND weapon_id = ?',
      [req.user.id, weapon_id]
    );

    let cartItemId;
    if (existingRows.length > 0) {
      cartItemId = existingRows[0].id;
      const newQty = existingRows[0].quantity + qty;
      await db.query('UPDATE cart_items SET quantity = ? WHERE id = ?', [newQty, cartItemId]);
    } else {
      const [result] = await db.query(
        'INSERT INTO cart_items (user_id, weapon_id, quantity) VALUES (?, ?, ?)',
        [req.user.id, weapon_id, qty]
      );
      cartItemId = result.insertId;
    }

    const [rows] = await db.query(
      `SELECT c.id AS id, c.user_id, c.weapon_id, c.quantity,
              w.name, w.type, w.description, w.stock, w.image_url, w.price
       FROM cart_items c
       JOIN weapons w ON w.id = c.weapon_id
       WHERE c.id = ?`,
      [cartItemId]
    );

    const row = rows[0];
    return res.status(201).json({
      success: true,
      data: {
        id: row.id,
        user_id: row.user_id,
        weapon_id: row.weapon_id,
        quantity: row.quantity,
        weapon: {
          id: row.weapon_id,
          name: row.name,
          type: row.type,
          description: row.description,
          stock: row.stock,
          image_url: row.image_url,
          price: parseFloat(row.price),
        },
      },
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { quantity } = req.body;
    if (quantity == null) {
      return res.status(400).json({ success: false, message: 'Quantity is required.' });
    }
    const qty = parseInt(quantity, 10);
    if (qty < 1) {
      return res.status(400).json({ success: false, message: 'Quantity must be at least 1.' });
    }

    const [cartRows] = await db.query(
      'SELECT weapon_id FROM cart_items WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (cartRows.length === 0) {
      return res.status(404).json({ success: false, message: 'Cart item not found.' });
    }

    const weaponId = cartRows[0].weapon_id;
    const [weaponRows] = await db.query('SELECT stock FROM weapons WHERE id = ?', [weaponId]);
    if (weaponRows.length === 0 || weaponRows[0].stock < qty) {
      return res.status(400).json({ success: false, message: 'Requested quantity exceeds stock.' });
    }

    await db.query('UPDATE cart_items SET quantity = ? WHERE id = ?', [qty, req.params.id]);

    const [rows] = await db.query(
      `SELECT c.id AS id, c.user_id, c.weapon_id, c.quantity,
              w.name, w.type, w.description, w.stock, w.image_url, w.price
       FROM cart_items c
       JOIN weapons w ON w.id = c.weapon_id
       WHERE c.id = ?`,
      [req.params.id]
    );

    const row = rows[0];
    return res.json({
      success: true,
      data: {
        id: row.id,
        user_id: row.user_id,
        weapon_id: row.weapon_id,
        quantity: row.quantity,
        weapon: {
          id: row.weapon_id,
          name: row.name,
          type: row.type,
          description: row.description,
          stock: row.stock,
          image_url: row.image_url,
          price: parseFloat(row.price),
        },
      },
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const [result] = await db.query('DELETE FROM cart_items WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Cart item not found.' });
    }
    return res.json({ success: true, message: 'Cart item removed.' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

router.post('/checkout', async (req, res) => {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    const [items] = await conn.query(
      `SELECT c.id, c.weapon_id, c.quantity, w.stock, w.price
       FROM cart_items c
       JOIN weapons w ON w.id = c.weapon_id
       WHERE c.user_id = ? FOR UPDATE`,
      [req.user.id]
    );

    if (items.length === 0) {
      await conn.rollback();
      return res.status(400).json({ success: false, message: 'Cart is empty.' });
    }

    for (const item of items) {
      if (item.stock < item.quantity) {
        await conn.rollback();
        return res.status(400).json({ success: false, message: `Not enough stock for item ${item.weapon_id}.` });
      }
    }

    for (const item of items) {
      const totalPrice = parseFloat(item.price) * item.quantity;
      await conn.query(
        'INSERT INTO orders (user_id, weapon_id, quantity, total_price, status) VALUES (?, ?, ?, ?, ?)',
        [req.user.id, item.weapon_id, item.quantity, totalPrice, 'confirmed']
      );
      await conn.query('UPDATE weapons SET stock = stock - ? WHERE id = ?', [item.quantity, item.weapon_id]);
    }

    await conn.query('DELETE FROM cart_items WHERE user_id = ?', [req.user.id]);
    await conn.commit();

    return res.json({ success: true, message: 'Checkout completed.' });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  } finally {
    conn.release();
  }
});

module.exports = router;
