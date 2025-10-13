import { Room, Client } from "@colyseus/core";
import { KrakoviaState } from "./schema/KrakoviaState";
import { Player } from "./schema/Player";
import { db } from "../db/connection";
import { schema } from "../db/schema";
import { eq, sql } from "drizzle-orm";
import { Monster } from "./schema/Monster";
import { loadMonsters } from "../data/monsters/load_monsters";
import { calculateMonsterDamage, calculatePlayerDamage } from "../mechanics/calculateDamage";
import { skills } from "../data/skills/skills_registry";
import { ExperienceTable } from "../data/exp_table/experience_table";
import { getSkillsByClass } from "../data/skills/skills";
import { generateLoot } from "../mechanics/generateLoot";
import { items } from "../data/items/items";
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
        max_health: monster.health,
        detectionRange: monster.detectionRange,
        attackCooldown: 2.0,
        attackTimer: 0.0,
        attackRange: 2.0,
        difficulty: monster.difficulty,
        experience: monster.experience,
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
        player.isAttacking = false
      }
    });

    this.onMessage("playerAttack", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.isAttacking = false
        const skill = skills.get(data.skillId)
        player.animation = "Idle";
        player.skillEffect = skill.effect
        player.targetId = data.targetId;
        this.broadcast("playerAttack", {
          id: client.sessionId,
          skillEffect: skill.effect,
          animation: skill.animation,
          targetId: data.targetId,
          isAttacking: false,
        });
      } 
    });

    this.onMessage("playerStartedAttack", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        const skill = skills.get(data.skillId)
        const target = this.state.monsters.get(data.targetId)
        const dx = target.x  - player.x
        const dz = target.z - player.z
        const distance = Math.sqrt(dx * dx + dz * dz)
        if (distance > skill.range) {
          client.send("too_far_away")
        } else {
          player.isAttacking = true
          player.animation = skill.animation;
          player.skillId = skill.id
        }
      } 
    });
    this.onMessage("equipItem", (client, data) =>{
      const player = this.state.players.get(client.sessionId)
      if (player) {
        const equippedItem = items[data.itemId]
        if (equippedItem.limitedClasses.includes(player.character_class)){
          player.defense += equippedItem.defense
        }
      }
    })
    this.onMessage("looted", (client, data) => {
      const player = this.state.players.get(data.playerId);
      // Loot Gold
      if (data.itemId === 1) {
        player.gold += data.itemQuantity
      } else {
        const lootedItem = items[data.itemId]
        const payload: any = {
          itemId: lootedItem.id,
          name: lootedItem.name,
          quantity: data.itemQuantity,
          description: lootedItem.description,
          type: lootedItem.type,
          limitedClasses: lootedItem.limitedClasses
        };
        if (lootedItem.type === "Armor" || lootedItem.type === "Helmet") {
          payload.attack = 0
          payload.defense = lootedItem.defense;
        }
        if (lootedItem.type === "Weapon") {
          payload.attack = lootedItem.attack;
          payload.defense = 0
        }

        client.send("looted_item", payload);
      }
    })
    this.onMessage("attackDealDamage", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        const target = this.state.monsters.get(data.targetId)
        if (!target || target.isDead) return
        if (target.health === target.max_health) {
          target.taggedPlayerId = player.id
        }
        if (!target._threatTable) {
          target._threatTable = {};
        }
        const skill = skills.get(data.skillId)
        const finalDamage = calculatePlayerDamage(player, target, skill)
        target._threatTable[player.id] = (target._threatTable[player.id] || 0) + finalDamage;
        target.health -= finalDamage
        target.isDead = target.health <= 0
        let topThreatPlayerId = target.targetId;
        let topThreatValue = -1;
        for (const [pid, threat] of Object.entries(target._threatTable)) {
          if (threat > topThreatValue) {
            topThreatValue = threat;
            topThreatPlayerId = pid;
          }
        }
        if (topThreatPlayerId !== target.targetId) {
          target.targetId = topThreatPlayerId;
          target.isAggroed = true;
        }
    
        this.broadcast("playerTargetHealthUpdate", {
          id: client.sessionId,
          targetId: target.monster_id,
          health: target.health,
          isDead: target.isDead,
          damage: finalDamage,
          taggedPlayer: target.taggedPlayerId
        });
        this.broadcast("damageDealt", {
          id: player.id,
          targetId: target.monster_id,
          damage: finalDamage,
        });
        if (target.isDead) {
          const loot = generateLoot(target)
          let levelsGained = 0
          const killer = this.state.players.get(target.taggedPlayerId)
          const killerClient = this.clients.find(c => c.sessionId === killer.id);
          if (killerClient) {
            killerClient.send("set_monster_loot", {"loot": loot, "loot_pos_x": target.x, "loot_pos_y": target.y, "loot_pos_z": target.z})
          }
          killer.experience += target.experience
          while (killer.experience >= ExperienceTable[killer.level]) {
            const requiredExp = ExperienceTable[killer.level];
            killer.experience -= requiredExp;
            killer.level += 1;
            killer.max_exp = ExperienceTable[killer.level];
            levelsGained += 1;
          }
          this.broadcast("experienceGained", {
            id: killer.id,
            taggedPlayerId: target.taggedPlayerId,
            experience: target.experience,
            maxExp: killer.max_exp,
            levelsGained: levelsGained,
            currentExperience: killer.experience
          });
          this.clock.setTimeout(() => {
            this.state.monsters.delete(target.monster_id);
          }, 1000)
        }
      } 
    })

    this.onMessage("moveMonster", (client, data) => {
      const monster = this.state.monsters.get(data.monsterId);
      if (!monster) return;
      
      monster.targetId = data.targetId;
      monster.isTargeting = data.isTargeting;
      monster.isAggroed = data.isAggroed;
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

      if (target && !target.isDead && !monster.isDead) {
        const dx = target.x - monster.x;
        const dz = target.z - monster.z;
        const distance = Math.sqrt(dx * dx + dz * dz);
        const dxSpawn = monster.x - monster.spawn_x;
        const dzSpawn = monster.z - monster.spawn_z;
        const distanceToSpawn = Math.sqrt(dxSpawn * dxSpawn + dzSpawn * dzSpawn);        
        if (distanceToSpawn > 40) {
          monster.isAggroed = false;
          monster.targetId = "";
          monster.isTargeting = false;
          monster.taggedPlayerId = "";
          monster.health = monster.max_health
          this.broadcast("playerTargetHealthUpdate", {
            id: target.id,
            targetId: monster.monster_id,
            health: monster.health,
          });
          return;
        }

        if (distance >= monster.attackRange) {
          const nx = dx / distance;
          const nz = dz / distance;
          const step = monster.speed * dt;

          const moveX = step >= distance ? dx : nx * step;
          const moveZ = step >= distance ? dz : nz * step;

          monster.x += moveX;
          monster.z += moveZ;
        }
        
        const attackRange = monster.attackRange;
        if (monster.attackTimer <= 0 && distance <= attackRange && monster.isAggroed && !monster.isDead) {
          if (!target.isDead) {
            monster.isTargeting = true
            const finalDamage = calculateMonsterDamage(monster, target);
            target.health -= finalDamage;
            this.broadcast("playerTargetHealthUpdate", {
              id: target.id,
              name: target.name,
              health: target.health,
              targetId: monster.targetId,
              isDead: target.health <= 0,
              damage: finalDamage,
            });
            if (target.health <= 0) {
              target.isDead = true;
              target.health = 0;
              // Remove player from threat table and retarget to new highest threat player
              this.state.monsters.forEach(monster => {
                delete monster._threatTable?.[target.id];
                if (monster.targetId === target.id) {
                  let topThreatValue = -Infinity;
                  let topThreatPlayerId = null;

                  for (const [pid, threat] of Object.entries(monster._threatTable || {})) {
                    if (threat > topThreatValue) {
                      topThreatValue = threat;
                      topThreatPlayerId = pid;
                    }
                  }

                  if (topThreatPlayerId) {
                    monster.targetId = topThreatPlayerId;
                    monster.isTargeting = true;
                  } else {
                    monster.targetId = "";
                    monster.isTargeting = false;
                  }
                }
              });

            }
          }
          monster.attackTimer = monster.attackCooldown;
        }
      } else {
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
          player.id = client.sessionId;
          player.name = character.name;
          player.character_class = character.class;
          player.health = character.health;
          player.max_health = character.max_health;
          player.mana = character.mana;
          player.max_mana = character.max_mana;
          player.experience = character.experience;
          player.max_exp = ExperienceTable[player.level]
          player.level = character.level;
          player.x = character.x_position;
          player.y = character.y_position;
          player.z = character.z_position;
          await db.update(schema.characters).set({
            lastLogin: sql`NOW()`
          })
          .where(eq(schema.characters.id, character.id))
        }
        const skills = getSkillsByClass(player.character_class)
        client.send("set_skills", skills);
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
