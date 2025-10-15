import { Skill } from "../data/skills/skills";
import { Monster } from "../rooms/schema/Monster";
import { Player } from "../rooms/schema/Player";

export function calculateMonsterDamage(monster: Monster, player: Player){
  let attackerDamage = monster.attack + getRandomInt(monster.difficulty + 5)
  attackerDamage -= player.defense
  if (attackerDamage < 0) {
    attackerDamage = 0
  }
  return attackerDamage
}

export function calculatePlayerDamage(player: Player, target: Monster, skill: Skill){
  let attackerDamage = skill.baseDamage + getRandomInt(player.level + 5)
  attackerDamage -= target.defense
  return attackerDamage
}

function getRandomInt(max: number) {
  return Math.floor(Math.random() * max);
}