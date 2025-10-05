import { Request, Response, Router } from 'express'
import { db } from '../../../db/connection';
import { eq, desc } from 'drizzle-orm';
import { schema } from '../../../db/schema';
import { authenticateToken } from '../../middleware/auth';

const router = Router()

router.get("/user", authenticateToken, async (req: Request, res: Response) => {
  const account_id = (req as any).account_id;

  const charactersList = await db.select()
                                  .from(schema.characters)
                                  .where(eq(schema.characters.account_id, account_id))
                                  .orderBy(desc(schema.characters.level))

  const user = await db.select({account_name: schema.accounts.account_name, createdAt: schema.accounts.createdAt})
                            .from(schema.accounts)
                            .where(eq(schema.accounts.id, account_id))

  const account = user[0]

  res.status(200).json({ user: account, characters: charactersList })
})

export default router