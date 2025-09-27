import { pgTable, text, uuid } from 'drizzle-orm/pg-core'

export const accounts = pgTable('accounts', {
  id: uuid().primaryKey().defaultRandom(),
  account_name: text().notNull(),
  password: text().notNull()
})