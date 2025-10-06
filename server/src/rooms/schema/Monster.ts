import { Schema, type } from '@colyseus/schema'
import { Player } from "./Player";

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
  @type("number") attack = 0
  @type("number") health = 0
  @type("number") detectionRange = 10
  @type("string") targetId = ""
  @type("number") attackTimer = 0
  @type("number") attackCooldown = 0
  @type("number") attackRange = 0
}