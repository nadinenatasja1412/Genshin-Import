var express = require('express');
var router = express.Router();

var userRoutes = require('./users');
var itemRoutes = require('./items');

router.use('/users', userRoutes);
router.use('/items', itemRoutes);

module.exports = router;
