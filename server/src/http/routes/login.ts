import { Request, Response, Router } from 'express'
import { db } from '../../db/connection';
import { accounts } from '../../db/schema/accounts';
import { eq } from 'drizzle-orm';

const router = Router()

interface LoginProps {
  username: string
  password: string
}

router.post("/login", async (req: Request<{}, {}, LoginProps>, res: Response) => {
  const { username, password } = req.body;
  try {
    const existing = await db.select().from(accounts).where(eq(accounts.account_name, username))
    if (existing.length > 0) {
      if (existing[0].password === password) {
        res.status(200).json({ message: "Login successful!" });
      } else {
        res.status(401).json({ message: "Login failed. Wrong username or password!" });
      }
    } else {
      res.status(404).json({ message: "User not found." });
    }
  } catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router