import { Router } from 'express'
import { db } from '../../db/connection';
import { eq, desc } from 'drizzle-orm';
import { schema } from '../../db/schema';

const router = Router()

router.get("/accounts/:account_id/characters", async (req, res) => {
  const { account_id } = req.params
  
  const charactersList = await db.select()
                                  .from(schema.characters)
                                  .where(eq(schema.characters.account_id, account_id))
                                  .orderBy(desc(schema.characters.level))

  res.status(200).json({ characters: charactersList })
})

export default router