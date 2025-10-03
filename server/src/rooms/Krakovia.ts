import { Room, Client } from "@colyseus/core";
import { KrakoviaState } from "./schema/KrakoviaState";
import { Player } from "./schema/Player";
import { db } from "../db/connection";
import { schema } from "../db/schema";
import { eq } from "drizzle-orm";

const GRAVITY = 75;
const JUMP_STRENGTH = 20;
const GROUND_LEVEL = 2;

export class Krakovia extends Room<KrakoviaState> {
  maxClients = 4;
  SPEED = 14
   
  onCreate(options: any) {
    this.state = new KrakoviaState();
    
    this.onMessage("move", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.inputX = data.x ?? 0;
        player.inputZ = data.z ?? 0;
        if (data.x !== 0 || data.z !== 0 && player.animation === "Idle") {
          player.animation = "Running";
        } else {
          player.animation = "Idle"
        }
      }
    });

    this.onMessage("look", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.dirX = data.dirX;
        player.dirY = 0;
        player.dirZ = data.dirZ;
      }
    });

    this.onMessage("jump", (client) => {
      const player = this.state.players.get(client.sessionId);
      if (player && player.isGrounded) {
        player.vy = JUMP_STRENGTH;
        player.isGrounded = false;
      }
    });
    
    this.setSimulationInterval((dtMs) => this.update(dtMs), 25);
  }
  update(dtMs: number) {
    const dt = dtMs / 1000; // convert to seconds

    this.state.players.forEach((player) => {
      // apply gravity
      player.vy -= GRAVITY * dt;
      const dx = player.inputX;
      const dz = player.inputZ;
      // integrate vertical position
      player.y += player.vy * dt;
      const len = Math.sqrt(dx * dx + dz * dz);
      if (len > 0) {
        player.x += (dx / len) * this.SPEED * dt;
        player.z += (dz / len) * this.SPEED * dt;
      }
      // ground collision
      if (player.y <= GROUND_LEVEL) {
        player.y = GROUND_LEVEL;
        player.vy = 0;
        player.isGrounded = true;
      }
    });
  }
  
  async onJoin(client: Client, options: { character_id: string }) {
    console.log(client.sessionId, "joined!");
    const player = new Player();
          
    if (options.character_id) {
      try {
        const characterFound = await db.select().from(schema.characters).where(eq(schema.characters.id, options.character_id));
        if (characterFound.length > 0) {
          const character = characterFound[0];
          player.name = character.name;
          player.character_class = character.class;
          player.health = character.health;
          player.mana = character.mana;
          player.experience = character.experience;
          player.level = character.level;
          player.x = character.x_position;
          player.y = character.y_position;
          player.z = character.z_position;
        }
      } catch (error) {
        console.log(error);
      }
    }
          
    this.state.players.set(client.sessionId, player);
  }

  onLeave(client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    this.state.players.delete(client.sessionId);
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }
}
