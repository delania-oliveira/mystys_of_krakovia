import { Skill } from "./skills"

export const AutoAttackHunter: Skill = {
  id: "auto_attack_hunter",
  name: "Auto Attack",
  baseDamage: 2,
  area: 0,
  animation: "AutoAttack",
  effect: "ArrowShot",
}

export const AutoAttackMage: Skill = {
  id: "auto_attack_mage",
  name: "Auto Attack",
  baseDamage: 4,
  area: 0,
  animation: "AutoAttack",
  effect: "Fireball",
}