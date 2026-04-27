import express from 'express';
import cors from 'cors';
import authRoutes from './route/authRoute';
import itemRoutes from './route/itemsRoute';
import transactionRoutes from './route/transactionsRoute';
import path from 'path';

const app = express();

app.use(cors());
app.use(express.json());

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

app.use('/api/auth', authRoutes);
app.use('/api', itemRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Genshin Import API running on http://localhost:${PORT}`);
});