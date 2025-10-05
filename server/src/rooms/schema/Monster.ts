import { Schema, type } from '@colyseus/schema'

export class Monster extends Schema {
  @type("string") monster_id = ""
  @type("string") name = ""
  @type("number") x = 0
  @type("number") y = 0
  @type("number") z = 0
  @type("number") spawn_x = 0
  @type("number") spawn_y = 0
  @type("number") spawn_z = 0
  @type("string") type = ""
  @type("number") inputX = 0
  @type("number") inputZ = 0
  @type("number") speed = 0
  @type("boolean") isTargeting = false
}