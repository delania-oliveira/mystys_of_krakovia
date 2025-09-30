import { Request, Response, Router } from 'express'
import { db } from '../../../db/connection';
import { eq } from 'drizzle-orm';
import { schema } from '../../../db/schema';
import { authenticateToken } from '../../middleware/auth';

const router = Router()

router.delete("/characters/:character_name", authenticateToken, async (req: Request<{}, {}, {character_name: string}>, res: Response) => {
  const account_id = (req as any).account_id;
  const { character_name } = req.body
  try {
    const existing = await db.select().from(schema.characters).where(eq(schema.characters.name, character_name))
    if (existing.length == 0 || existing[0].account_id != account_id) {
        res.status(401).json( { message: `Character with name ${character_name} doesn't exist!` });
    } else {
      await db.delete(schema.characters).where(eq(schema.characters.name, existing[0].name))
      res.status(200).json({ message: "Character deleted with success!" });
    }
  } catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router