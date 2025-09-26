import { doublePrecision, integer, pgTable, text, uuid } from "drizzle-orm/pg-core";
import { accounts } from "./accounts";

export const characters = pgTable("characters", {
  id: uuid().primaryKey().defaultRandom(),
  account_id: uuid().references(() => accounts.id).notNull(),
  x_position: doublePrecision().notNull().default(0),
  y_position: doublePrecision().notNull().default(0),
  z_position: doublePrecision().notNull().default(0),
  name: text().notNull(),
  class: integer().notNull(),
  level: integer().notNull().default(1),
  health: integer().notNull(),
  mana: integer().notNull(),
  experience: integer().notNull(),
})