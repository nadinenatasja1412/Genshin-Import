const express = require('express');
const router = express.Router();

const userRoutes = require('./users');
const itemRoutes = require('./items');
const transactionRoutes = require('./transaction');

router.use('/users', userRoutes);
router.use('/items', itemRoutes);
router.use('/transactions', transactionRoutes);

module.exports = router;