import { z } from 'zod'
import 'dotenv/config'

const envSchema = z.object({
  DATABASE_URL: z.url().startsWith('postgres://'),
  PRIVATE_KEY: z.string(),
})
export const env = envSchema.parse(process.env)