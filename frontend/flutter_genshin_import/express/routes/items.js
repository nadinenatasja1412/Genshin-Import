var express = require('express');
var router = express.Router();
var itemController = require('../controllers/itemController');
var multer = require('multer');
var path = require('path');

// Konfigurasi Multer untuk simpan gambar
var storage = multer.diskStorage({
    destination: 'uploads/',
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

var upload = multer({ storage });

// GET /api/items (Ambil semua barang)
router.get('/', itemController.getAllItems);

// POST /api/items (Tambah barang + Upload gambar)
router.post('/', upload.single('image'), itemController.createItem);

// PUT /api/items/:id (Update barang)
router.put('/:id', itemController.updateItem);

// DELETE /api/items/:id (Hapus barang)
router.delete('/:id', itemController.deleteItem);

module.exports = router;