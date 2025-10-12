import { Schema, type } from "@colyseus/schema";

export class Player extends Schema {
    @type("string") id = "";
    @type("number") x = 0;
    @type("number") y = 0;
    @type("number") z = 0;
    @type("number") vx = 0;
    @type("number") vy = 0;
    @type("number") vz = 0;
    @type("number") dirX = 0;
    @type("number") dirY = 0;
    @type("number") dirZ = -1;
    @type("number") inputX = 0;
    @type("number") inputZ = 0;
    @type("boolean") isGrounded = true;
    @type("string") name = "";
    @type("string") character_class = "";
    @type("number") health = 1;
    @type("number") max_health = 1;
    @type("number") mana = 1;
    @type("number") max_mana = 1;
    @type("number") level = 1;
    @type("number") experience = 0;
    @type("string") animation = "Idle"
    @type("boolean") isDead = false
    @type("string") targetId = ""
    @type("number") targetHealth = 0
    @type("string") targetName = ""
    @type("number") defense = 0
    @type("string") skillEffect = ""
    @type("boolean") isAttacking = false
    @type("number") max_exp = 0
    @type("string") skillId = ""
    @type("number") gold = 0
    @type("number") lootId = 0
}