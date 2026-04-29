var express = require('express');
var router = express.Router();
var authController = require('../controller/authController');

// Route untuk registrasi
router.post('/register', authController.register);

// Route untuk login
router.post('/login', authController.login);

module.exports = router;
