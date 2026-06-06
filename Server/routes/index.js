const express = require('express');
const router = express.Router();

const authRoutes = require('./users');
const weaponRoutes = require('./weapons');
const orderRoutes = require('./orders');
const cartRoutes = require('./cart');

router.use('/auth', authRoutes);
router.use('/weapons', weaponRoutes);
router.use('/orders', orderRoutes);
router.use('/cart', cartRoutes);

module.exports = router;