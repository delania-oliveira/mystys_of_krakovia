import { Request, Response, Router } from 'express'
import { db } from '../../db/connection';
import { accounts } from '../../db/schema/accounts';
import { eq } from 'drizzle-orm';

const router = Router()

interface LoginProps {
  username: string
  password: string
}

router.post("/register", async (req: Request<{}, {}, LoginProps>, res: Response) => {
  const { username, password } = req.body;
  try {
    const existing = await db.select().from(accounts).where(eq(accounts.account_name, username))
    if (existing.length > 0) {
        res.status(401).json( { message: "Username already exists!" });
    } else {
      const result = await db.insert(accounts).values({
        account_name: username,
        password: password
      }).returning()
      const newAccount = result[0]
      if (!newAccount) {
        throw new Error("Failed to create account")
      }
      res.status(201).json({ message: "Account created with success!" });
    }
  } catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router