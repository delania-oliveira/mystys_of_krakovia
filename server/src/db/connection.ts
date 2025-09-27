import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import { schema } from './schema/index'
import { env } from '../env'
export const sql = postgres(env.DATABASE_URL)

export const db = drizzle(sql, {
  schema,
  casing: 'snake_case',
})