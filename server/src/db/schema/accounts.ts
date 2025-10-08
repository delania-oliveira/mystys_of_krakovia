import { pgTable, text, uuid, timestamp } from 'drizzle-orm/pg-core'

export const accounts = pgTable('accounts', {
  id: uuid().primaryKey().defaultRandom(),
  account_name: text().notNull(),
  password: text().notNull(),
  createdAt: timestamp('created_at').notNull().defaultNow(),
})