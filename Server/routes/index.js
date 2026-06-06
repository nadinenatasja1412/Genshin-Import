const express = require('express');
const router = express.Router();

const authRoutes = require('./users');
const weaponRoutes = require('./weapons');
const orderRoutes = require('./orders');

router.use('/auth', authRoutes);
router.use('/weapons', weaponRoutes);
router.use('/orders', orderRoutes);

module.exports = router;