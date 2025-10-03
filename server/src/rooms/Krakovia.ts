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
    
    // Example: handle custom messages
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

    this.onMessage("login", async (client: Client, data: { id: string; }) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        try {
          const characterFound = await db.select().from(schema.characters).where(eq(schema.characters.id, data.id))
          if (characterFound.length > 0) {
            const character = characterFound[0]
            player.name = character.name
            player.health = character.health
            player.mana = character.mana
            player.experience = character.experience
            player.level = character.level
            player.x = character.x_position
            player.y = character.y_position
            player.z = character.z_position
          }
          client.send("login", { 
            success: true,
            sessionId: client.sessionId,
            x: player.x,
            y: player.y,
            z: player.z
          })
        } catch (error) {
          console.log(error)
          client.send("loginError", { success: false, message: "Database error" })          
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
      player.inputX = 0;
      player.inputZ = 0;
    });
  }
  
  onJoin(client: Client, options: any) {
    console.log(client.sessionId, "joined!");
    const player = new Player();
    this.state.players.set(client.sessionId, player);
    // THIS will trigger players:add on all clients
  }

  onLeave(client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    this.state.players.delete(client.sessionId);
    // THIS will trigger players:remove on all clients
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }
}
