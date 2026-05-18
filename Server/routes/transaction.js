const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');

router.post('/buy', transactionController.buyItem);

router.get('/', transactionController.getTransactionHistory);

module.exports = router;