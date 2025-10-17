import { doublePrecision, integer, pgTable, text, uuid, timestamp } from "drizzle-orm/pg-core";
import { accounts } from "./accounts";

export const characters = pgTable("characters", {
  id: uuid().primaryKey().defaultRandom(),
  account_id: uuid().references(() => accounts.id).notNull(),
  x_position: doublePrecision().notNull().default(0),
  y_position: doublePrecision().notNull().default(0),
  z_position: doublePrecision().notNull().default(0),
  spawn_x: doublePrecision().default(0),
  spawn_z: doublePrecision().default(0),
  gold: doublePrecision().default(0),
  name: text().notNull(),
  class: text().notNull(),
  level: integer().notNull().default(1),
  health: integer().notNull(),
  max_health: integer().notNull(),
  mana: integer().notNull(),
  max_mana: integer().notNull(),
  experience: integer().notNull().default(0),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  lastLogin: timestamp('last_login')
})