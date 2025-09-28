import { Request, Response, Router } from 'express'
import { db } from '../../db/connection';
import { accounts } from '../../db/schema/accounts';
import { eq } from 'drizzle-orm';

const router = Router()

router.post("/check_username", async (req: Request<{}, {}, {username: string}>, res: Response) => {
  const { username } = req.body;
  try {
    const existing = await db.select().from(accounts).where(eq(accounts.account_name, username))
    if (existing.length > 0) {
      res.status(200).json({ available: false });
    } else {
      res.status(200).json({ available: true });
    }
  } catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router