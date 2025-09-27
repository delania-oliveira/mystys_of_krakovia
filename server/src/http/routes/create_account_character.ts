import { Request, Response, Router } from 'express'
import { db } from '../../db/connection';
import { eq } from 'drizzle-orm';
import { schema } from '../../db/schema';

const router = Router()

interface CharacterCreationProps {
  name: string,
  character_class: string,
}

router.post("/accounts/:account_id/create_character", async (req: Request<{account_id: string}, {}, CharacterCreationProps>, res: Response) => {
  const { name, character_class } = req.body;
  const { account_id } = req.params
  try {
    const existing = await db.select().from(schema.characters).where(eq(schema.characters.name, name))
    if (existing.length > 0) {
        res.status(401).json( { message: `Character with name ${name} already exists!` });
    } else {
      const result = await db.insert(schema.characters).values({
        name: name,
        class: character_class,
        account_id: account_id,
        health: 100,
        mana: 85,
      }).returning()
      const newCharacter = result[0]
      if (!newCharacter) {
        throw new Error("Failed to create account")
      }
      res.status(201).json({ message: "Character created with success!" });
    }
  } catch (error) {
    console.log(error)
    res.status(401).json({ message: "Database error!" });       
  }
})

export default router