import { Skill } from "./skills"

export const MultiShotArcher: Skill = {
  id: "multi_shot_archer",
  name: "Tiro Múltiplo",
  level: 1,
  baseDamage: 2,
  range: 30,
  area: 10,
  animation: "AttackMultiShot",
  effect: "ArrowMultiShot",
  characterClass: "Archer",
  description: "Atira flechas em múltiplos alvos",
  needTarget: true,
  cooldown: 3.0,
  manaCost: 10
}
