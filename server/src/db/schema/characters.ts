import { doublePrecision, integer, pgTable, serial, text } from "drizzle-orm/pg-core";
import { accounts } from "./accounts";

export const characters = pgTable("characters", {
  id: serial('id').primaryKey(),
  account_id: integer().references(() => accounts.id).notNull(),
  x_position: doublePrecision().notNull().default(0),
  y_position: doublePrecision().notNull().default(0),
  z_position: doublePrecision().notNull().default(0),
  name: text().notNull(),
  class: integer().notNull(),
  level: integer().notNull().default(1)
})