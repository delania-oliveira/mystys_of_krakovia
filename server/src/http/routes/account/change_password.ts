import { Request, Response, Router } from 'express'
import { db } from '../../../db/connection';
import { eq } from 'drizzle-orm';
import { comparePassword, hashPassword } from '../../lib/bcrypt';
import { authenticateToken } from '../../middleware/auth';
import { schema } from '../../../db/schema';

const router = Router()

interface ChangePasswordParams {
  currentPassword: string
  newPassword: string
}

router.post("/change_password", authenticateToken, async (req: Request<{}, {}, ChangePasswordParams>, res: Response) => {
  const account_id = (req as any).account_id;

  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword) return res.status(400).json({message: "Must provide current or new password!"})
  try {
    const account = await db.select().from(schema.accounts).where(eq(account_id, schema.accounts.id))
    const match = account[0].password == currentPassword
    if (!match) return res.status(400).json({message: "Current Password incorrect!"})
    const hashedPassword = await hashPassword(newPassword)
    await db.update(schema.accounts).set({password: hashedPassword}).where(eq(schema.accounts.id, account_id))
    res.status(200).json({ message: "Password updated with success!" });
  }
  catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router