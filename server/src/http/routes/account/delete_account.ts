import { Request, Response, Router } from 'express'
import { db } from '../../../db/connection';
import { eq } from 'drizzle-orm';
import { schema } from '../../../db/schema';
import { authenticateToken } from '../../middleware/auth';

const router = Router()

router.delete("/accounts", authenticateToken, async (req: Request<{}, {}, {}>, res: Response) => {
  const account_id = (req as any).account_id;

  try {
    await db.delete(schema.characters).where(eq(schema.characters.account_id, account_id));
    await db.delete(schema.accounts).where(eq(schema.accounts.id, account_id));
    res.status(200).json({ message: "Account deleted with success!" });
  } catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router