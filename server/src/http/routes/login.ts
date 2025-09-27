import { Request, Response, Router } from 'express'
import { db } from '../../db/connection';
import { accounts } from '../../db/schema/accounts';
import { eq } from 'drizzle-orm';
import { comparePassword } from '../lib/bcrypt';

const router = Router()

interface LoginProps {
  username: string
  password: string
}

router.post("/login", async (req: Request<{}, {}, LoginProps>, res: Response) => {
  const { username, password } = req.body;
  try {
    const existing = await db.select().from(accounts).where(eq(accounts.account_name, username))
    if (existing.length > 0 && comparePassword(password, existing[0].password)) {
        res.status(200).json({ message: existing[0].id });
    } else {
        res.status(401).json({ message: "Login failed. Wrong username or password!" });
    } 
  } catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router