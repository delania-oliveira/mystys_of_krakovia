import { Room, Client } from "@colyseus/core";
import { KrakoviaState } from "./schema/KrakoviaState";
import { Player } from "./schema/Player";
import { db } from "../db/connection";
import { schema } from "../db/schema";
import { eq, sql } from "drizzle-orm";
import { Monster } from "./schema/Monster";
import { loadMonsters } from "../data/monsters/load_monsters";
import { calculateDamage } from "../mechanics/calculateDamage";

const GRAVITY = 75
const JUMP_STRENGTH = 20
const GROUND_LEVEL = 3
const PLAYER_SPEED = 14

export class Krakovia extends Room<KrakoviaState> {
  maxClients = 4;
  hasProcessedAttack = false
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
        spawn_x: monster.x,
        spawn_y: GROUND_LEVEL - 1,
        spawn_z: monster.z,
        speed: monster.speed,
        attack: monster.attack,
        health: monster.health,
        detectionRange: monster.detectionRange,
        attackCooldown: 2.0,
        attackTimer: 0.0,
        attackRange: 2.0
      });
  
      this.state.monsters.set(loadedMonster.monster_id, loadedMonster);
    })

    this.onMessage("movePlayer", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.inputX = data.x ?? 0;
        player.inputZ = data.z ?? 0;
        const isMoving = Math.abs(data.x) >= 0.1 || Math.abs(data.z) >= 0.1;
        player.animation = isMoving ? "Running" : "Idle";
      } 
    });

    this.onMessage("moveMonster", (client, data) => {
      const monster = this.state.monsters.get(data.monsterId);
      if (!monster) return;
      
      monster.targetId = data.targetId;
      monster.isTargeting = data.isTargeting;
    });

    this.onMessage("setTarget", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.targetName = data.targetName
      }
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
      monster.attackTimer -= dt;
      if (monster.attackTimer < 0) monster.attackTimer = 0;

      const target = this.state.players.get(monster.targetId);

      if (target) {
        // direction FROM monster TO target (was the bug)
        const dx = target.x - monster.x;
        const dz = target.z - monster.z;
        const distance = Math.sqrt(dx * dx + dz * dz);

        if (distance > 0.1) {
          const nx = dx / distance;
          const nz = dz / distance;
          const step = monster.speed * dt;

          // avoid overshooting: if step >= distance, move exactly to target vector
          const moveX = step >= distance ? dx : nx * step;
          const moveZ = step >= distance ? dz : nz * step;

          monster.x += moveX;
          monster.z += moveZ;
        }

        const attackRange = monster.attackRange;
        if (monster.attackTimer <= 0 && distance <= attackRange) {
          if (!target.isDead) {
            monster.isTargeting = true
            const finalDamage = calculateDamage(monster.attack);
            target.health -= finalDamage;
            this.broadcast("playerHealthUpdate", {
              name: target.name,
              health: target.health,
              targetId: monster.targetId,
              targetHealth: target.health,
              isDead: target.health <= 0,
            });
            if (target.health <= 0) {
              target.isDead = true;
              target.health = 0;
              monster.targetId = "";
              monster.isTargeting = false;
            }
          }
          monster.attackTimer = monster.attackCooldown;
        }
      } else {
        monster.isTargeting = false
        const dirX = monster.spawn_x - monster.x;
        const dirZ = monster.spawn_z - monster.z;
        const dist = Math.sqrt(dirX * dirX + dirZ * dirZ);

        if (dist > 0.1) {
          const nx = dirX / dist;
          const nz = dirZ / dist;
          const step = monster.speed * dt;
          const moveX = step >= dist ? dirX : nx * step;
          const moveZ = step >= dist ? dirZ : nz * step;

          monster.x += moveX;
          monster.z += moveZ;
        }
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
          player.max_health = character.max_health;
          player.mana = character.mana;
          player.max_mana = character.max_mana;
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
