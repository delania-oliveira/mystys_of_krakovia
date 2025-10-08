import { pgTable, text, serial } from 'drizzle-orm/pg-core'

export const accounts = pgTable('accounts', {
  id: serial('id').primaryKey(),
  account_name: text().notNull(),
  password: text().notNull()
})