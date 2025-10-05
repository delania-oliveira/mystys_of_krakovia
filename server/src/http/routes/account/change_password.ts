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
    const hashedPassword = await hashPassword(newPassword)
    const match = comparePassword(newPassword, currentPassword);
    if (!match) return res.status(400).json({message: "Current Password incorrect!"})
    await db.update(schema.accounts).set({password: hashedPassword}).where(eq(schema.accounts.id, account_id))
    res.status(200).json({ message: "Password updated with success!" });
  }
  catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router