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
import { levelUp } from "../mechanics/levelUp";
const GRAVITY = 75
const JUMP_STRENGTH = 20
const GROUND_LEVEL = 3
const PLAYER_SPEED = 14

export class Krakovia extends Room<KrakoviaState> {
  maxClients = 4;
  hasProcessedAttack = false
  private monsterSpawns = new Map<string, Monster>();
  private damagedTargets: Monster[] = []

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
        respawn: monster.respawn
      });
      this.monsterSpawns.set(loadedMonster.monster_id, loadedMonster);
      this.state.monsters.set(loadedMonster.monster_id, loadedMonster);
    })
  
    this.onMessage("movePlayer", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.inputX = data.x;
        player.inputZ = data.z;
        const isMoving = Math.abs(data.x) >= 0.1 || Math.abs(data.z) >= 0.1;
        player.animation = isMoving ? "Running" : "Idle";
        player.isAttacking = false
      }
    });

    this.onMessage("partyInvite", (client, data) => {
      const invitingPlayer = this.state.players.get(data.playerInvitingId)
      const invitedPlayer = this.state.players.get(data.invitedPlayerId)
      const invitedPlayerClient = this.clients.find(c => c.sessionId === invitedPlayer.id);
      const invitingPlayerClient = this.clients.find(c => c.sessionId === invitingPlayer.id);

      if (invitedPlayer.partyId){
        invitingPlayerClient.send("inviteFail", {"text": "Jogador já está em um grupo!"})
        return
      }

      if (invitingPlayer.partyId && invitingPlayer.partyId !== invitingPlayer.id){
        invitingPlayerClient.send("inviteFail", {"text": "Você não é o líder do grupo!"})
        return
      }

      invitedPlayerClient.send("partyInvite", {"invitingPlayerName": invitingPlayer.name, "invitingPlayerId": invitingPlayer.id})
    })

    this.onMessage("addToParty", (client, data) => {
      const invitingPlayer = this.state.players.get(data.playerInvitingId);
      const invitedPlayer = this.state.players.get(data.playerInvitedId);
      let newParty = false
      if (!invitingPlayer || !invitedPlayer) return;
      if (invitedPlayer.partyId) {
        // send message later
        return
      }
      if (invitingPlayer.partyId && invitingPlayer.id != invitingPlayer.partyId) {
        return
      }
      if (!invitingPlayer._party) {
        invitingPlayer._party = {};
      }
      let partyId = invitingPlayer.partyId;
      if (!partyId) {
        partyId = invitingPlayer.id
        invitingPlayer.partyId = partyId;
        invitingPlayer._party[partyId] = [invitingPlayer];
        newParty = true
      }
      invitedPlayer.partyId = partyId;
      invitingPlayer._party[partyId].push(invitedPlayer);
      const invitingClient = this.clients.find(c => c.sessionId === invitingPlayer.id);
      const invitedClient = this.clients.find(c => c.sessionId === invitedPlayer.id);
      const partyMembers = invitingPlayer._party[partyId].map(p => ({
        id: p.id,
        name: p.name,
        max_health: p.max_health,
        current_health: p.health,
        level: p.level,
        character_class: p.character_class
      }));

      if (invitedClient && invitingClient && newParty) {
        invitedClient.send("partyJoined", { leader: partyId, members: partyMembers });
        invitingClient.send("partyJoined", { leader: partyId, members: partyMembers });
      } else {
        const party = invitingPlayer._party[partyId];
        party.forEach(member => {
          const memberClient = this.clients.find(c => c.sessionId === member.id);

          if (memberClient) {
            memberClient.send("partyJoined", { leader: partyId, members: partyMembers });
          }
        });
      }
    });

   this.onMessage("leaveParty", (client, data) => {
    const player = this.state.players.get(client.sessionId);
    if (player && player.partyId) {
      const partyId = player.partyId;
      const partyLeader = this.state.players.get(partyId);
      const party = partyLeader._party[partyId];

      party.forEach(member => {
        const memberClient = this.clients.find(c => c.sessionId === member.id);
        if (memberClient) {
          memberClient.send("leaveParty", { leavingMember: player.id });
        }
      });

      const updatedParty = party.filter(member => member.id !== player.id);
      partyLeader._party[partyId] = updatedParty;

      player.partyId = "";

      if (updatedParty.length <= 1) {
        const lastMember = updatedParty[0];
        if (lastMember) {
          const memberClient = this.clients.find(c => c.sessionId === lastMember.id);
          if (memberClient) {
            memberClient.send("leaveParty", { leavingMember: lastMember.id });
          }
          lastMember.partyId = "";
        }
        delete partyLeader._party[partyId];
        }
      }
    });

    this.onMessage("playerAttack", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        this.damagedTargets = []
        player.isAttacking = false
        player.animation = "Idle"
        const skill = skills.get(data.skillId)
        player.skillEffect = skill.effect
        const payload: any = {
          id: client.sessionId,
          skillId: skill.id,
          skillEffect: skill.effect,
          animation: skill.animation,
          isAttacking: false,
          area: skill.area,
          targetId: data.targetId
        };
        player.targetId = data.targetId;
        payload.needTarget = true
        if (!skill.needTarget) {
          payload.needTarget = false
        }
        if (skill.castTime) {
          player.castTime = skill.castTime
        }
        this.broadcast("playerAttack", payload);
      } 
    });

    this.onMessage("playerBuff", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.isAttacking = false
        player.animation = "Idle"
        const skill = skills.get(data.skillId)
        player.defense += skill.buffDef
        player.attack += skill.buffAtk
        this.clock.setTimeout(() => {
            player.defense -= skill.buffDef
            player.attack -= skill.buffDef
          }, skill.buffDuration * 1000);
      } 
    });

    this.onMessage("playerStartedAttack", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        const skill = skills.get(data.skillId)
        if (skill.level > player.level) {
          client.send("skillFail", {"text": "Level muito baixo para usar a skill!"})
          return
        }
        if (skill.needTarget) {
          const target = this.state.monsters.get(data.targetId)
          if (!target) return
          const dx = target.x  - player.x
          const dz = target.z - player.z
          const distance = Math.sqrt(dx * dx + dz * dz)
          if (distance > skill.range) {
            client.send("skillFail", {"text": "Inimigo muito distante!"})
          } else {
            player.isAttacking = true
            player.animation = skill.animation;
            player.skillId = skill.id
            if (skill.castTime) {
              player.castTime = skill.castTime
            }
          }
        } else {
          player.isAttacking = true
          player.animation = skill.animation;
          player.skillId = skill.id
          if (skill.castTime) {
            player.castTime = skill.castTime
          }
        }
      }
    });
    
    this.onMessage("equipItem", (client, data) =>{
      const player = this.state.players.get(client.sessionId)
      if (player) {
        const equippedItem = items[data.itemId]
        if ((equippedItem.limitedClasses.includes(player.character_class) || equippedItem.limitedClasses.includes("Todas")) && equippedItem.defense){
          player.defense += equippedItem.defense
        } else {
          player.attack += equippedItem.attack
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
        const skill = skills.get(data.skillId)
        if (skill.needTarget && !target || target.isDead) return
        if (target.health === target.max_health) {
          target.taggedPlayerId = player.id
        }
        if (!target._threatTable) {
          target._threatTable = {};
        }
        
        const finalDamage = calculatePlayerDamage(player, target, skill)
        player.animation = "Idle"
        if (!this.damagedTargets.includes(target)){
          if (player.character_class == "Warrior"){
            target._threatTable[player.id] = (target._threatTable[player.id] || 0) + finalDamage * 1.50;
          } else {
            target._threatTable[player.id] = (target._threatTable[player.id] || 0) + finalDamage;
          }
          target.health -= finalDamage
        }
        target.isDead = target.health <= 0
        if (skill.area > 0){
          this.damagedTargets.push(target)
        }
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
          const monsterIdToRespawn = target.monster_id;
          const loot = generateLoot(target)
          const monsterData = this.monsterSpawns.get(monsterIdToRespawn);
          this.clock.setTimeout(() => {
            this.state.monsters.delete(monsterIdToRespawn);
          }, 1000);
          this.clock.setTimeout(() => {
            if (monsterData) {
              const respawnedMonster = new Monster().assign({
                monster_id: monsterData.monster_id,
                type: monsterData.type,
                name: monsterData.name,
                x: monsterData.spawn_x,
                y: GROUND_LEVEL - 1,
                z: monsterData.spawn_z,
                spawn_x: monsterData.spawn_x,
                spawn_y: GROUND_LEVEL - 1,
                spawn_z: monsterData.spawn_z,
                speed: monsterData.speed,
                attack: monsterData.attack,
                health: monsterData.max_health,
                max_health: monsterData.max_health,
                detectionRange: monsterData.detectionRange,
                attackCooldown: 2.0,
                attackTimer: 0.0,
                attackRange: 2.0,
                difficulty: monsterData.difficulty,
                experience: monsterData.experience,
                respawn: monsterData.respawn
              });

              this.state.monsters.set(respawnedMonster.monster_id, respawnedMonster);
            }
          }, monsterData.respawn * 1000);
          const killer = this.state.players.get(target.taggedPlayerId)
          const partyId = killer.partyId
          const killerClient = this.clients.find(c => c.sessionId === killer.id);
          if (killerClient && !partyId) {
            let levelsGained = 0;

            killerClient.send("set_monster_loot", {
              loot,
              loot_pos_x: target.x,
              loot_pos_y: target.y,
              loot_pos_z: target.z
            });

            killer.experience += target.experience;

            while (killer.experience >= ExperienceTable[killer.level]) {
              killer.experience -= ExperienceTable[killer.level];
              levelUp(killer);
              levelsGained++;
            }

            killer.max_exp = ExperienceTable[killer.level];

            killerClient.send("experienceGained", {
              experience: target.experience,
              maxExp: killer.max_exp,
              levelsGained,
              currentExperience: killer.experience
            });

          } else if (partyId) {
            const partyLeader = this.state.players.get(partyId);
            const party = partyLeader._party[partyId];
            const memberCount = party.length;
            const bonusMultiplier = 1 + (0.25 * (memberCount - 1));
            const share = Math.floor((target.experience * bonusMultiplier) / memberCount);

            const membersLeveledUp: any[] = []

            party.forEach(member => {
              let levelsGained = 0;
              const memberClient = this.clients.find(c => c.sessionId === member.id);

              member.experience += share;

              while (member.experience >= ExperienceTable[member.level]) {
                member.experience -= ExperienceTable[member.level];
                levelUp(member);
                levelsGained++;
              }

              if (levelsGained != 0){
                membersLeveledUp.push({
                  id: member.id,
                  name: member.name,
                  level: member.level,
                  character_class: member.character_class,
                  partyId: member.partyId
                })
              }

              if (membersLeveledUp.length > 0) {
                this.broadcast("partyMemberLevelUp", { membersLeveledUp });
              }

              member.max_exp = ExperienceTable[member.level];
              
              if (memberClient) {
                memberClient.send("experienceGained", {
                  id: member.id,
                  partyId: member.partyId,
                  experience: share,
                  maxExp: member.max_exp,
                  levelsGained,
                  currentExperience: member.experience,
                  membersLeveledUp: membersLeveledUp
                });
                memberClient.send("set_monster_loot", {
                  loot,
                  loot_pos_x: target.x,
                  loot_pos_y: target.y,
                  loot_pos_z: target.z
                });
              }
            });
          }

        }
      } 
    })
    this.onMessage("respawnPlayer", (client, data) => {
      const player = this.state.players.get(client.sessionId)
      if (player) {
        player.x = 0
        player.y = 3
        player.z = 0
        player.isDead = false
        player.health = player.max_health
        player.animation = "Idle"
      }
    })

    this.onMessage("unstuck", (client, data) => {
      const player = this.state.players.get(client.sessionId)
      if (player) {
        player.x = 0
        player.y += 10
        player.vy = 100;
        player.z = 0
        player.animation = "Idle"
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
          if (monster._threatTable) {
            monster._threatTable = {};
          }
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
          monster.animation = "Running"
        }
        
        const attackRange = monster.attackRange;
        if (monster.attackTimer <= 0 && distance <= attackRange && monster.isAggroed && !monster.isDead) {
          if (!target.isDead) {
            monster.isTargeting = true
            monster.animation = "Attack"
            const finalDamage = calculateMonsterDamage(monster, target);
            if (finalDamage === 0) {
              const targetClient = this.clients.find(c => c.sessionId === target.id);
              targetClient.send("resistDamage")
              return
            }
            target.health -= finalDamage;
            this.broadcast("playerTargetHealthUpdate", {
              id: target.id,
              name: target.name,
              health: target.health,
              targetId: monster.targetId,
              isDead: target.health <= 0,
              damage: finalDamage,
            });
            const partyId = target.partyId
            if (partyId) {
              const partyLeader = this.state.players.get(partyId)
              const party = partyLeader._party[partyId];
              party.forEach(member => {
                const memberClient = this.clients.find(c => c.sessionId === member.id);
                
                if (memberClient) {
                  memberClient.send("partyHealthUpdate", { member: target.id, health: target.health });
                }
              });
            }
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
                    monster.animation = "Idle"
                  } else {
                    monster.targetId = "";
                    monster.animation = "Running"
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
          monster.animation = "Running"
        } else {
          monster.animation = "Idle"
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
          player.dbId = options.character_id;
          player.name = character.name;
          player.character_class = character.class;
          player.health = character.health;
          player.max_health = character.max_health;
          player.mana = character.mana;
          player.max_mana = character.max_mana;
          player.experience = character.experience;
          player.max_exp = ExperienceTable[character.level]
          player.level = character.level;
          player.attack = player.attack
          player.gold = player.gold
          player.defense = player.level
          player.attack = player.level
          player.x = character.spawn_x;
          player.y = 3;
          player.z = character.spawn_z;
          player.spawn_x = character.spawn_x
          player.spawn_z = character.spawn_z
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

  async onLeave(client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    const player = this.state.players.get(client.sessionId)
    try {
      await db.update(schema.characters).set({
        health: player.health,
        max_health: player.max_health,
        mana: player.mana,
        max_mana: player.max_mana,
        experience: player.experience,
        level: player.level,
        gold: player.gold,
        spawn_x: player.x,
        spawn_z: player.z
      }).where(eq(schema.characters.id, player.dbId));
    } catch (error) {
      console.log(error)
    }

    this.state.players.delete(client.sessionId);
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }
}
