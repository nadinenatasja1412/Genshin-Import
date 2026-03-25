import { Router } from 'express';
import { buyItem } from '../controllers/transaction-controllers';

const router = Router();

router.post('/buy', buyItem); 

export default router;