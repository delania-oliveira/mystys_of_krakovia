import { Schema, type } from "@colyseus/schema";

export class Player extends Schema {
    @type("number") x = 0;
    @type("number") y = 0;
    @type("number") z = 0;
    @type("number") vx = 0;
    @type("number") vy = 0;
    @type("number") vz = 0;
    @type("number") dirX = 0;
    @type("number") dirY = 0;
    @type("number") dirZ = -1;
    @type("boolean") isGrounded = true;
}