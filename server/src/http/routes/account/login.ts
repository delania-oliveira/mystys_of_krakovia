import { Request, Response, Router } from 'express'
import { db } from '../../../db/connection';
import { accounts } from '../../../db/schema/accounts';
import { eq } from 'drizzle-orm';
import { comparePassword } from '../../lib/bcrypt';
import jsonwebtoken from 'jsonwebtoken'
import { env } from '../../../env';

const router = Router()

interface LoginParams {
  username: string
  password: string
}

router.post("/login", async (req: Request<{}, {}, LoginParams>, res: Response) => {
  const { username, password } = req.body;
  try {
    const existing = await db.select().from(accounts).where(eq(accounts.account_name, username))
    if (existing.length === 0) {
      return res.status(404).json({ message: "Login failed. Username not found!" });
    }

    const match = await comparePassword(password, existing[0].password)

    if (!match) {
      return res.status(401).json({ message: "Login failed. Wrong password!" });
    }
    const token = jsonwebtoken.sign(
      { account_id: existing[0].id },
      env.PRIVATE_KEY,
      { expiresIn: "30d" }
    )
    res.status(200).json({ username, token });
  } catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router