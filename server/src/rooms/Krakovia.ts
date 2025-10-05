import { Room, Client } from "@colyseus/core";
import { KrakoviaState } from "./schema/KrakoviaState";
import { Player } from "./schema/Player";
import { db } from "../db/connection";
import { schema } from "../db/schema";
import { eq, sql } from "drizzle-orm";
import { Monster } from "./schema/Monster";
import { loadMonsters } from "../data/monsters/load_monsters";

const GRAVITY = 75
const JUMP_STRENGTH = 20
const GROUND_LEVEL = 3
const PLAYER_SPEED = 14

export class Krakovia extends Room<KrakoviaState> {
  maxClients = 4;
   
  onCreate(options: any) {
    this.state = new KrakoviaState();
    const monsters = loadMonsters()
    monsters.map(monster => {
      const loadedMonster = new Monster().assign({
        monster_id: monster.id,
        type: monster.type,
        name: monster.name,
        x: monster.x,
        y: GROUND_LEVEL - 1,
        z: monster.z,
        speed: monster.speed
      });
  
      this.state.monsters.set(loadedMonster.monster_id, loadedMonster);
    })

    this.onMessage("movePlayer", (client, data) => {
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

    this.onMessage("moveMonster", (client, data) => {
      const monster = this.state.monsters.get(data.monster_id);
      monster.inputX = data.x ?? 0;
      monster.inputZ = data.z ?? 0;
    });

    this.onMessage("lookPlayer", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.dirX = data.dirX;
        player.dirY = 0;
        player.dirZ = data.dirZ;
      }
    });

    this.onMessage("jumpPlayer", (client) => {
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
        player.x += (dx / len) * PLAYER_SPEED * dt;
        player.z += (dz / len) * PLAYER_SPEED * dt;
      }
      // ground collision
      if (player.y <= GROUND_LEVEL ) {
        player.y = GROUND_LEVEL;
        player.vy = 0;
        player.isGrounded = true;
      }
    });

    this.state.monsters.forEach((monster) => {
      const dx = monster.inputX;
      const dz = monster.inputZ;
      const len = Math.sqrt(dx * dx + dz * dz);
      if (len > 0) {
        monster.x += (dx / len) * monster.speed * dt;
        monster.z += (dz / len) * monster.speed * dt;
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
          await db.update(schema.characters).set({
            lastLogin: sql`NOW()`
          })
          .where(eq(schema.characters.id, character.id))
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
